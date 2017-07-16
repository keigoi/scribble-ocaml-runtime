let (!%) = Printf.sprintf

module Chan = Channel    
    
module MChan : sig
  (* the entry point *)
  type 't shared
  val create_connect_first : unit -> [`ConnectFirst] shared
  val create_connect_later : string list -> [`ConnectLater] shared

  (* a session channel to communicate with another role *)
  type t
  val accept : [`ConnectFirst] shared -> myname:string -> cli_count:int -> t
  val connect : [`ConnectFirst] shared -> myname:string -> t
  val initiate : [`ConnectLater] shared -> myname:string -> t
  val connect_ongoing : t -> to_:string -> unit
  val accept_ongoing : t -> from_:string -> unit
  val disconnect : t -> from_:string -> unit
  val myname : t -> string
  val get_connection : t -> othername:string -> Unsafe.UChan.t
end = struct
  
  type connect_one = {from_:string; to_:string; connection:Unsafe.UChan.t}
         
  (* 'session hash' is a hash table from role id to untyped session chan *)
  type t = {name: string; sess: (string, Unsafe.UChan.t) Hashtbl.t; connector: [`ConnectLater] shared option}

  (* entry point -- shared channel; 
     the payload is the client's id and a typed channel to send bach
     the session hash   *)
   and 't shared =
     | ConnectFirst: (string * t Chan.t) Chan.t -> [`ConnectFirst] shared
     | ConnectLater: (string, connect_one Chan.t) Hashtbl.t -> [`ConnectLater] shared
                         
  let create_connect_first () = ConnectFirst (Chan.create ())
  let create_connect_later names =
    let hash = Hashtbl.create 42 in
    List.iter (fun name -> Hashtbl.add hash name (Chan.create ())) names;
    ConnectLater hash

  let initiate (hash:[`ConnectLater] shared) ~myname =
    {name=myname;sess=Hashtbl.create 42;connector=Some hash}

  let connect_ongoing {name;sess;connector} ~to_ =
    match connector with
    | None -> failwith "connect_ongoing: explicit connection used in implicit-connection session"
    | Some (ConnectLater hash) -> begin
        let connector = Hashtbl.find hash to_ in
        let conn = Unsafe.UChan.create () in
        Chan.send connector {from_=name;to_;connection=conn};
        assert (not (Hashtbl.mem sess to_));
        Hashtbl.add sess to_ conn
      end

  let accept_ongoing {name;sess;connector} ~from_ =
    match connector with
    | None -> failwith (!%"accept_ongoing at %s: explicit connection used in implicit-connection session" name)
    | Some (ConnectLater hash) -> begin
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

  let disconnect {name;sess} ~from_ =
    Hashtbl.remove sess from_
     
  let accept (ConnectFirst sh) ~myname ~cli_count =
    let me = myname in

    (* accept all connections *)
    let rethash = Hashtbl.create 42 in
    let rec gather cnt =
      if cnt > 0 then begin
        let rolename,ret = Chan.receive sh in
        Hashtbl.add rethash rolename ret;
        gather (cnt-1)
      end
    in
    gather cli_count;
    
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
        Chan.send ret {name=r1; sess=otherhash; connector=None};
        (* don't forget to prepare mine! *)
        Hashtbl.add myhash r1 s;
      ) rethash;
    {name=myname; sess=myhash; connector=None}

  let connect (ConnectFirst sh) ~myname =
    let ret = Chan.create () in
    Chan.send sh (myname,ret);
    Chan.receive ret

  let myname {name} = name
    
  let get_connection {sess=myhash} ~othername =
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
