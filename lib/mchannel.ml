module Make(IO:Channel.IO)
         (Chan:Channel.S with type 'a io = 'a IO.io)
         (Mutex:Channel.MUTEX with type 'a io = 'a IO.io)
         (Cond:Channel.CONDITION with type 'a io = 'a IO.io and type m = Mutex.t)
         (RawDChan:Base.RAW_DCHAN with type 'a io = 'a IO .io)
         (Endpoint:Base.ENDPOINT with type 'a io = 'a IO.io)
       : Base.RAW_MCHAN with type raw = RawDChan.t
  = struct

  module Endpoint = Endpoint

  type t = {
      acceptor_role:string;
      connector_roles:string list;
      m: Mutex.t;
      c: Cond.t;
      waitors: (string, Endpoint.t Chan.t) Hashtbl.t;
    }
  type raw = RawDChan.t
  type _ Endpoint.conn_kind += Raw : raw Endpoint.conn_kind

  let create ~acceptor_role ~connector_roles =
    {acceptor_role;
     connector_roles;
     waitors=Hashtbl.create 42;
     m=Mutex.create();
     c=Cond.create()}

  let create_or_get_session =
    let cache = Hashtbl.create 42 in fun r1 r2 ->
                                     try
                                       Hashtbl.find cache (r1,r2)
                                     with
                                     | Not_found ->
                                        try
                                          Hashtbl.find cache (r2,r1)
                                        with
                                        | Not_found -> begin
                                            let s = RawDChan.create () in
                                            let s = {Endpoint.handle=s; close=(fun ()-> IO.return ())} in
                                            Hashtbl.add cache (r1,r2) s;
                                            s
                                          end

  let establish hash me others =
    let open IO in
    let my_edp = Endpoint.create ~myname:me in

    (* iterate on other roles to send back the session hash
         (and prepare my session hash)  *)
    let res =
      List.map (fun r1 ->
          let r1_edp = Endpoint.create ~myname:r1 in

          (* add session channels to roles other than me *)
          List.iter (fun r2 ->
              if r1<>r2 then begin
                  let s = create_or_get_session r1 r2 in
                  Endpoint.attach r1_edp (Endpoint.create_key Raw r2) s;
                end) others;

          (* then add the session channel between me and r1 *)
          let s = create_or_get_session me r1 in
          Endpoint.attach r1_edp (Endpoint.create_key Raw me) s;
          Endpoint.attach my_edp (Endpoint.create_key Raw r1) s;

          (* and send back *)
          (r1, r1_edp)
        ) others
    in
    let rec send_all = function
      | [] -> return ()
      | (r,edp)::rs -> Chan.send (Hashtbl.find hash r) edp >>= fun () -> send_all rs
    in
    send_all res >>= fun () ->
    return my_edp

  let gather t hash roles =
    let rec loop todo =
      function
      | [] -> todo
      | r::roles ->
         if Hashtbl.mem t.waitors r then begin
             Hashtbl.add hash r (Hashtbl.find t.waitors r);
             Hashtbl.remove t.waitors r;
             loop todo roles
           end else begin
             loop (r::todo) roles
           end
    in
    loop [] roles

  let accept t =
    let open IO in
    let hash = Hashtbl.create 42 in
    let rec loop rest =
      let rest = gather t hash rest in
      if rest = []
      then
        return ()
      else begin
          Cond.wait t.c t.m >>= fun () ->
          loop rest
        end
    in
    Mutex.lock t.m >>= fun () ->
    loop t.connector_roles >>= fun () ->
    Mutex.unlock t.m;
    establish hash t.acceptor_role t.connector_roles

  let connect t ~role =
    let open IO in
    Mutex.lock t.m >>= fun () ->
    let chan = Chan.create () in
    Hashtbl.add t.waitors role chan;
    Cond.signal t.c;
    Mutex.unlock t.m;
    Chan.receive chan
end
