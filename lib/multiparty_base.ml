module UChan : sig (* untyped *)
  type t
  val create : unit -> t
  val receive : t -> 'a
  val send : t -> 'a -> unit
end = struct
  type t = unit Event.channel
  let create = Event.new_channel
  let receive c = Obj.magic (Event.sync (Event.receive c))
  let send c v = Event.sync (Event.send c (Obj.magic v ))
end

module Chan = Channel    
    
module MChan : sig
  (* (\* the entry point *\) *)
  type shared
  val create : unit -> shared
    
  (* a session channel to communicate with another role *)
  type t
  val accept : shared -> myname:string -> cli_count:int -> t
  val connect : shared -> myname:string -> t
  val get_connection : t -> othername:string -> UChan.t
end = struct
  (* 'session hash' is a hash table from role id to untyped session chan *)
  type t = (string, UChan.t) Hashtbl.t

  (* entry point -- shared channel; 
     the payload is the client's id and a typed channel to send bach
     the session hash   *)
  type shared = (string * t Chan.t) Chan.t
                         
  let create = Chan.create
                    
                    
  let accept sh ~myname ~cli_count =
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
             let s = UChan.create () in
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
        Chan.send ret otherhash;
        (* don't forget to prepare mine! *)
        Hashtbl.add myhash r1 s;
      ) rethash;
    myhash

  let connect sh ~myname =
    let ret = Chan.create () in
    Chan.send sh (myname,ret);
    Chan.receive ret
    
  let get_connection myhash ~othername =
    try
      Hashtbl.find myhash othername
    with
    | Not_found ->
       failwith
         (Printf.sprintf
            "impossible: session channel to %s not found"
            othername)
end
