open Linocaml.Base
open Linocaml.Lens

module Make(LinIO:Linocaml.Base.LIN_IO)
           (Chan:Base.CHAN with type 'a io = 'a LinIO.IO.io)
           (RawChan:Base.RAW_DCHAN with type 'a io = 'a LinIO.IO.io)
: Base.SESSION with type 'a io = 'a LinIO.IO.io and type ('p,'q,'a) monad = ('p,'q,'a) LinIO.monad
= struct
  module Endpoint = Endpoint.Make(LinIO.IO)
  module Raw = RawChan

  module LinIO = LinIO
  module IO = LinIO.IO
  module E = Endpoint

  type 'a io = 'a LinIO.IO.io
  type ('p,'q,'a) monad = ('p,'q,'a) LinIO.monad

  type 'a lin = 'a Linocaml.Base.lin
  type 'a data = 'a Linocaml.Base.data

  type 'p sess_ = EP of Endpoint.t | Dummy
  type 'p sess = 'p sess_ lin

  type 'c connector = 'c Endpoint.connector
  type 'c acceptor = 'c Endpoint.acceptor

  let shmem () =
    let handle = Raw.create () in
    (fun () -> IO.return {Endpoint.handle; close=(fun _ -> IO.return ())}),
    (fun () -> IO.return {Endpoint.handle=Raw.reverse handle; close=(fun _ -> IO.return ())})

  type 'a Endpoint.conn_kind += Shmem : Raw.t Endpoint.conn_kind

  let unsess = function
    | (Lin_Internal__ (EP s)) -> s
    | _ -> failwith "no session -- malformed ppx expansion??"
  let sess s = Lin_Internal__ (EP s)

  type ('roles, 'conn, 'labels) role = {_pack_role: 'conn * 'labels -> 'roles; _repr:string; _kind:'conn Endpoint.conn_kind}
  type ('labels, 'conn, 'payloads) label = {_pack_label: 'payloads -> 'labels; _send:'conn -> 'labels -> unit io}
  type ('labels, 'conn) labels = {_receive:'conn -> 'labels io}

  let dummy = Lin_Internal__ Dummy

  (* [`send of [`alice of [`msg of 'conn * 'v data * 'p sess]] sess *)
  let send :
        'conn 'v 'p.
        (([>] as 'roles, 'conn, ([>] as 'labels)) role *  ('labels, 'conn, 'v data * 'p sess) label * 'v)
        -> ([`send of 'roles] sess, empty, 'p sess) monad = fun (role, lab, v) ->
    LinIO.Internal.__monad begin fun s ->
      let s = unsess s in
      let conn = Endpoint.get_connection s (Endpoint.create_key role._kind role._repr)
      and s = sess s in
      let open IO in
      lab._send conn.Endpoint.handle (lab._pack_label (Data v, s)) >>= fun () ->
      return (Empty, s)
      end

  let real_receive s receiver c =
    let open IO in
    receiver c >>= fun br ->
    (* we must replace 'p sess part, since the part in payload is Dummy (see send) *)
    let br = Unsafe.replace_sess_part br (Lin_Internal__ (EP s)) in
    return br

  let receive :
        'conn 'role.
        ([>] as 'role, 'conn, ([>] as 'labels)) role * ('labels, 'conn) labels
        -> ([`recv of 'role] sess, empty, 'labels lin) monad = fun (role, labels) ->
    LinIO.Internal.__monad begin fun s ->
      let s = unsess s in
      let conn = Endpoint.get_connection s (Endpoint.create_key role._kind role._repr) in
      let open IO in
      real_receive s labels._receive conn.Endpoint.handle >>= fun lab ->
      return (Empty, Lin_Internal__ lab)
      end

  let close : ([`close] sess, empty, unit lin) monad =
    LinIO.Internal.__monad begin fun s ->
      let s = unsess s in
      let open IO in
      E.close s >>= fun () ->
      return (Empty, Lin_Internal__ ())
      end

  let deleg_send
      : 'conn 'p 'q.
        (([>] as 'roles, 'conn, ([>] as 'labels)) role *  ('labels, 'conn, 'q sess * 'p sess) label)
        -> ([`send of 'roles] sess * 'q sess, empty, 'p sess) monad = fun (role, label) ->
    LinIO.Internal.__monad begin fun (s,t) ->
      let s = unsess s in
      let conn = Endpoint.get_connection s (Endpoint.create_key role._kind role._repr)
      and s = sess s in
      let open IO in
      label._send conn.Endpoint.handle (label._pack_label (t, s)) >>= fun () ->
      return (Empty, s)
      end

  let connect :
        'conn connector
        -> (([>] as 'roles, 'conn, ([>] as 'labels)) role *  ('labels, 'conn, 'v data * 'p sess) label * 'v)
        -> ([`connect of 'roles] sess, empty, 'p sess) monad = fun connector (role, label, v) ->
    LinIO.Internal.__monad begin fun s ->
      let s = unsess s in
      let open IO in
      connector () >>= fun conn ->
      E.attach s (Endpoint.create_key role._kind role._repr) conn;
      let s = sess s in
      label._send conn.Endpoint.handle (label._pack_label (Data v, s)) >>= fun () ->
      return (Empty, s)
      end

  let real_accept s acceptor receiver =
    let open IO in
    acceptor () >>= fun c ->
    real_receive s receiver c.Endpoint.handle >>= fun br ->
    return (c, br)

  let accept :
        'conn acceptor
        -> ([>] as 'role, 'conn, ([>] as 'labels)) role * ('labels, 'conn) labels
        -> ([`accept of 'role] sess, empty, 'labels lin) monad = fun acceptor (role, labels) ->
    LinIO.Internal.__monad begin fun s ->
        let s = unsess s in
        let open IO in
        real_accept s acceptor labels._receive >>= fun (conn, br) ->
        E.attach s (Endpoint.create_key role._kind role._repr) conn;
        return (Empty, Lin_Internal__ br)
      end

  let disconnect :
        ([>] as 'role, 'conn, 'p sess) role
        -> ([`disconnect of 'role] sess, empty, 'p sess) monad = fun role ->
    LinIO.Internal.__monad begin fun s ->
        let s = unsess s in
        let open IO in
        E.disconnect s (Endpoint.create_key role._kind role._repr)  >>= fun _ ->
        return (Empty, Lin_Internal__ (EP s))
      end

  let connect_corr :
        'conn connector
        -> ([>] as 'roles, 'conn, ([>] as 'labels)) role *  ('labels, 'conn * 'corr, 'v data * 'p sess) label * 'corr * 'v
        -> ([`connect of 'roles] sess, empty, 'p sess) monad = fun connector (role, label, corr, v) ->
    LinIO.Internal.__monad begin fun s ->
      let s = unsess s in
      let open IO in
      connector () >>= fun conn ->
      E.attach s (Endpoint.create_key role._kind role._repr) conn;
      let s = sess s in
      label._send (conn.Endpoint.handle, corr) (label._pack_label (Data v, s)) >>= fun () ->
      return (Empty, s)
      end

  let real_accept_corr s acceptor receiver corr =
    let open IO in
    acceptor () >>= fun c ->
    real_receive s receiver (c.Endpoint.handle, corr) >>= fun br ->
    return (c, br)

  let accept_corr :
        'conn acceptor
        -> ([>] as 'role, 'conn, ([>] as 'labels)) role * ('labels, 'conn * 'corr) labels * 'corr
        -> ([`accept of 'role] sess, empty, 'labels lin) monad = fun acceptor (role, labels, corr) ->
    LinIO.Internal.__monad begin fun s ->
        let s = unsess s in
        let open IO in
        real_accept_corr s acceptor labels._receive corr >>= fun (conn, br) ->
        E.attach s (Endpoint.create_key role._kind role._repr) conn;
        return (Empty, Lin_Internal__ br)
      end

  module Internal = struct
    let __initiate : myname:string -> ('c, 'c, 'p sess) LinIO.monad
      = fun ~myname ->
      LinIO.Internal.__monad begin
          fun pre ->
          let s = E.create ~myname in
          IO.return (pre, (Lin_Internal__ (EP s)))
        end

    let __create_connector c = c
    let __create_acceptor a = a
  end
end
