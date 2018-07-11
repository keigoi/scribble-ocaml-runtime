module Make
         (IO:S.IO)
         (Mutex:S.MUTEX with type 'a io = 'a IO.io)
         (Cond:S.CONDITION with type 'a io = 'a IO.io with type m = Mutex.t)
         (Endpoint:S.ENDPOINT with type 'a io = 'a IO.io)
  = struct

  module Chan : S.CHAN with type 'a io = 'a IO.io
    = struct
    open IO
    module Q = Queue

    type +'a io = 'a IO.io
    type 'a t = 'a Q.t * Mutex.t * Cond.t

    let create () : 'a t = Q.create (), Mutex.create (), Cond.create ()

    let send (q,m,c) v =
      Mutex.lock m >>= fun _ ->
      Q.add v q;
      Cond.signal c;
      Mutex.unlock m;
      return ()

    let receive (q,m,c) =
      Mutex.lock m >>= fun _ ->
      let rec loop () =
        if Q.is_empty q then
          Cond.wait c m >>=
            loop
        else
          return (Q.take q)
      in
      loop () >>= fun v ->
      Mutex.unlock m;
      return v
  end

  module DChan : S.DCHAN with type 'a io = 'a Chan.io
    = struct
    type +'a io = 'a Chan.io
    type 'a t = 'a Chan.t * 'a Chan.t

    let create () = Chan.create (), Chan.create ()
    let send (w,_) v = Chan.send w v
    let receive (_,r) = Chan.receive r
    let reverse (w,r) = (r,w)
  end

  module Raw : S.RAW with type 'a io = 'a Mutex.io
    = struct
    type +'a io = 'a IO.io
    type t = unit DChan.t
    let create = DChan.create
    let send c v = DChan.send c (Obj.magic v)
    let receive c = Obj.magic (DChan.receive c)
    let reverse c = DChan.reverse c
  end


  module MPSTChannel : S.SHMEM_ENDPOINT with type raw = Raw.t with module Endpoint = Endpoint
    = struct

    module Endpoint = Endpoint

    type _ Endpoint.conn_kind += Raw : Raw.t Endpoint.conn_kind

    type t = {
        acceptor_role:string;
        connector_roles:string list;
        m: Mutex.t;
        c: Cond.t;
        waitors: (string, Endpoint.t Chan.t) Hashtbl.t;
      }
    type raw = Raw.t

    let create ~acceptor_role ~connector_roles =
      {acceptor_role;
       connector_roles;
       waitors=Hashtbl.create 42;
       m=Mutex.create();
       c=Cond.create()}

    let create_or_get_session =
      let cache = Hashtbl.create 42 in
      fun r1 r2 ->
      try
        Hashtbl.find cache (r1,r2)
      with
      | Not_found -> begin
             let s = Raw.create () in
             let ep s = {Endpoint.handle=s; close=(fun ()-> IO.return ())} in
             Hashtbl.add cache (r1,r2) (ep s);
             Hashtbl.add cache (r2,r1) (ep (Raw.reverse s));
             ep s
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
            let s = create_or_get_session r1 me in
            Endpoint.attach r1_edp (Endpoint.create_key Raw me) s;
            let s = create_or_get_session me r1 in
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
           if Hashtbl.mem t.waitors r
           then begin
               Hashtbl.add hash r (Hashtbl.find t.waitors r);
               Hashtbl.remove t.waitors r;
               loop todo roles
             end
           else begin
               loop (r::todo) roles
             end
      in
      loop [] roles

    let accept t ~role =
      if t.acceptor_role <> role then
        failwith (Printf.sprintf "not an acceptor: %s (expected: %s). Maybe bug in code generator?" role t.acceptor_role);
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
end
