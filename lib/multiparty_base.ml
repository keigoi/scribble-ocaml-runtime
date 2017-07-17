let (!%) = Printf.sprintf

module Chan = Channel    
    
module MChan : sig
  (* the entry point *)
  type 't shared
  val create : unit -> [`Implicit] shared
  val create_lazy : unit -> [`Implicit] shared
  val create_later : string list -> [`Explicit] shared

  (* a session channel to communicate with another role *)
  type t
  val accept : [`Implicit] shared -> myname:string -> cli_count:int -> t
  val connect : [`Implicit] shared -> myname:string -> t
  val initiate : [`Explicit] shared -> myname:string -> t
  val connect_ongoing : t -> to_:string -> unit
  val accept_ongoing : t -> from_:string -> unit
  val disconnect : t -> from_:string -> unit
  val myname : t -> string
  val get_connection : t -> othername:string -> Unsafe.UChan.t
end = struct
  
  type connect_one = {from_:string; to_:string; connection:Unsafe.UChan.t}
  type session = (string, Unsafe.UChan.t) Hashtbl.t
         
  (* 'session hash' is a hash table from role id to untyped session chan *)
  type t = {name: string; sess: session Lazy.t; connector: [`Explicit] shared option}

  (* entry point -- shared channel; 
     the payload is the client's id and a typed channel to send bach
     the session hash   *)
   and 't shared =
     | Implicit: (string * session Chan.t) Chan.t -> [`Implicit] shared
     | Lazy: (string * session Chan.t) Chan.t -> [`Implicit] shared
     | Explicit: (string, connect_one Chan.t) Hashtbl.t -> [`Explicit] shared
                         
  let create () = Implicit (Chan.create ())
  let create_lazy () = Lazy (Chan.create ())
  let create_later names =
    let hash = Hashtbl.create 42 in
    List.iter (fun name -> Hashtbl.add hash name (Chan.create ())) names;
    Explicit hash

  let initiate (hash:[`Explicit] shared) ~myname =
    {name=myname;sess=Lazy.from_val (Hashtbl.create 42);connector=Some hash}

  let connect_ongoing {name;sess=lazy sess;connector} ~to_ =
    match connector with
    | None -> failwith "connect_ongoing: explicit connection used in implicit-connection session"
    | Some (Explicit hash) -> begin
        let connector = Hashtbl.find hash to_ in
        let conn = Unsafe.UChan.create () in
        Chan.send connector {from_=name;to_;connection=conn};
        assert (not (Hashtbl.mem sess to_));
        Hashtbl.add sess to_ conn
      end

  let accept_ongoing {name;sess=lazy sess;connector} ~from_ =
    match connector with
    | None -> failwith (!%"accept_ongoing at %s: explicit connection used in implicit-connection session" name)
    | Some (Explicit hash) -> begin
        let connector = Hashtbl.find hash name in
        let {from_=realfrom;to_=realto;connection=conn} = Chan.receive connector in
        if from_<>realfrom then begin
            failwith (!%"accept_ongoing at %s: unexpected connection from %s, expected: %s" name from_ realfrom)
          end;
        if name<>realto then begin
            failwith (!%"accept_ongoing at %s: wrong connection from %s, should connect to:%s" name from_ realto)
          end;
        assert (not (Hashtbl.mem sess from_));
        Hashtbl.add sess from_ conn
      end

  let disconnect {name;sess=lazy sess} ~from_ =
    Hashtbl.remove sess from_
     
  let accept sh ~myname ~cli_count =
    let sh,lazy_ = match sh with Implicit sh -> sh,false | Lazy sh -> sh,true in
    let me = myname in

    (* accept all connections *)
    let rethash = Hashtbl.create 42 in
    let rec gather cnt =
      if cnt > 0 then begin
          let rolename,ret = Chan.receive sh in
          if Hashtbl.mem rethash rolename then
            failwith (Printf.sprintf "role %s already connected. TODO: fix this to block rather than fail" rolename)
          else
            Hashtbl.add rethash rolename ret;
          gather (cnt-1)
        end
    in
    
    (* hashtbl to record sessions between (r1,r2) *)
    let hashhash = Hashtbl.create 42
    in
    (* a function to create the session channel between r1 and r2 *)
    let create_or_get_session r1 r2 =
      try
        Hashtbl.find hashhash (r1,r2)
      with
      | Not_found ->
         try
           Hashtbl.find hashhash (r2,r1)
         with
         | Not_found -> begin
             let s = Unsafe.UChan.create () in
             Hashtbl.add hashhash (r1,r2) s;
             s
           end
    in
    (* my session hash *)
    let myhash = Hashtbl.create 42
    in
    let make () =
      gather cli_count;
      (* iterate on other roles to send back the session hash
         (and prepare my session hash)  *)
      Hashtbl.iter (fun r1 ret ->
          let otherhash = Hashtbl.create 42 in
          (* add session channels to roles other than the parent (me) *)
          Hashtbl.iter (fun r2 _ ->
              if r2 <> me && r1<>r2 then begin
                  let s = create_or_get_session r1 r2 in
                  Hashtbl.add otherhash r2 s
                end
            ) rethash;
          (* then add the connection to me *)
          let s = create_or_get_session me r1 in
          Hashtbl.add otherhash me s;
          (* and send back *)
          Chan.send ret otherhash;
          (* don't forget to prepare mine! *)
          Hashtbl.add myhash r1 s;
        ) rethash;
      myhash
    in
    let sess =
      if lazy_ then
        Lazy.from_fun make
      else
        Lazy.from_val (make ())
    in
    {name=myname; sess=sess; connector=None}

  let connect sh ~myname =
    let sh, lazy_ = match sh with Implicit sh -> sh,false | Lazy sh -> sh, true in
    let make () = 
      let ret = Chan.create () in
      Chan.send sh (myname,ret);
      Chan.receive ret
    in
    let sess =
      if lazy_ then
        Lazy.from_fun make
      else
        Lazy.from_val (make ())
    in
    {name=myname;sess;connector=None}
    
      

  let myname {name} = name
    
  let get_connection {sess=lazy myhash} ~othername =
    try
      Hashtbl.find myhash othername
    with
    | Not_found ->
       let msg =
         let r = ref [] in
         Hashtbl.iter (fun x _ -> r := x ::!r) myhash;
         !%"impossible: session channel to %s not found; %s"
            othername (String.concat "," !r)
       in
       failwith msg
       (* failwith *)
       (*   (Printf.sprintf *)
       (*      "impossible: session channel to %s not found" *)
       (*      othername) *)
end
