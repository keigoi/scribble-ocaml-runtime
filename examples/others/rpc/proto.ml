(* Generated from scribble-ocaml https://github.com/keigoi/scribble-ocaml
 * This code should be compiled with scribble-ocaml-runtime
 * https://github.com/keigoi/scribble-ocaml-runtime *)


module Make (Session:Scribble.S.SESSION)  = struct


open Session

type ('c_S1, 'c_S2, 'c_S3) proto_C = ('c_S1, 'c_S2, 'c_S3) proto_C_1
and ('c_S1, 'c_S2, 'c_S3) proto_C_1 =
  [`send of [`S1 of 'c_S1 * [`_1 of unit data *
    [`recv of [`S1 of 'c_S1 * [`_1a of unit data *
      [`close] sess]]] sess]]]
type ('c_C, 'c_S2, 'c_S3) proto_S1 = ('c_C, 'c_S2, 'c_S3) proto_S1_1
and ('c_C, 'c_S2, 'c_S3) proto_S1_1 =
  [`recv of [`C of 'c_C * [`_1 of unit data *
    [`send of [`S2 of 'c_S2 * [`_2 of unit data *
      [`recv of [`S2 of 'c_S2 * [`_2a of unit data *
        [`send of [`S3 of 'c_S3 * [`_3 of unit data *
          [`recv of [`S3 of 'c_S3 * [`_3a of unit data *
            [`send of [`C of 'c_C * [`_1a of unit data *
              [`close] sess]]] sess]]] sess]]] sess]]] sess]]] sess]]]
type ('c_C, 'c_S1, 'c_S3) proto_S2 = ('c_C, 'c_S1, 'c_S3) proto_S2_1
and ('c_C, 'c_S1, 'c_S3) proto_S2_1 =
  [`recv of [`S1 of 'c_S1 * [`_2 of unit data *
    [`send of [`S1 of 'c_S1 * [`_2a of unit data *
      [`close] sess]]] sess]]]
type ('c_C, 'c_S1, 'c_S2) proto_S3 = ('c_C, 'c_S1, 'c_S2) proto_S3_1
and ('c_C, 'c_S1, 'c_S2) proto_S3_1 =
  [`recv of [`S1 of 'c_S1 * [`_3 of unit data *
    [`send of [`S1 of 'c_S1 * [`_3a of unit data *
      [`close] sess]]] sess]]]


module Shmem = Scribble.Shmem.Make(Session.LinIO.IO)(Session.Mutex)(Session.Condition)(Session.Endpoint)

type proto = ShmemMPSTChanenl__ of Shmem.MPSTChannel.t
let create_shmem_channel : unit -> proto = fun () ->
  ShmemMPSTChanenl__(Shmem.MPSTChannel.create ~acceptor_role:"role_C" ~connector_roles:["role_S1";; "role_S2"; "role_S3"])


module C = struct
  let initiate_shmem : 'c. proto -> ('c, 'c, Shmem.Raw.t proto_C sess) monad = fun (ShmemMPSTChanenl__(c)) ->
    Internal.__start (Shmem.MPSTChannel.accept c ~role:"role_C")

  module S1 = struct
    module Make(X:sig
        type conn
        val conn : conn Endpoint.conn_kind
        val write__1 : conn -> [>`_1 of unit data * 'p sess] -> unit io
        val read__1a : conn -> [`_1a of unit data * 'p0] io
      end) = struct
      type conn = X.conn
      let role : ([>`S1 of X.conn * 'lab], X.conn, 'lab) role =
        {_pack_role=(fun labels -> `S1(labels)) ; _repr="role_S1"; _kind=X.conn}

      let _1 : 'p. ([>`_1 of unit data * 'p sess], X.conn, unit data * 'p sess) label =
        {_pack_label=(fun payload -> `_1(payload)); _send=X.write__1}
      let receive__1a  : type p0. ([`_1a of unit data * p0], X.conn) labels =
        {_receive=X.read__1a}
    end

    module Raw = struct
      include Make(struct
          type conn = Shmem.Raw.t
          let conn = Shmem.MPSTChannel.Raw
          let write__1 = Shmem.Raw.send
          let read__1a = Shmem.Raw.receive
        end)
    end
  end
  module S2 = struct
    module Make(X:sig
        type conn
        val conn : conn Endpoint.conn_kind
      end) = struct
      type conn = X.conn
      let role : ([>`S2 of X.conn * 'lab], X.conn, 'lab) role =
        {_pack_role=(fun labels -> `S2(labels)) ; _repr="role_S2"; _kind=X.conn}

    end

    module Raw = struct
      include Make(struct
          type conn = Shmem.Raw.t
          let conn = Shmem.MPSTChannel.Raw
        end)
    end
  end
  module S3 = struct
    module Make(X:sig
        type conn
        val conn : conn Endpoint.conn_kind
      end) = struct
      type conn = X.conn
      let role : ([>`S3 of X.conn * 'lab], X.conn, 'lab) role =
        {_pack_role=(fun labels -> `S3(labels)) ; _repr="role_S3"; _kind=X.conn}

    end

    module Raw = struct
      include Make(struct
          type conn = Shmem.Raw.t
          let conn = Shmem.MPSTChannel.Raw
        end)
    end
  end

end

module S1 = struct
  let initiate_shmem : 'c. proto -> ('c, 'c, Shmem.Raw.t proto_S1 sess) monad = fun (ShmemMPSTChanenl__(c)) ->
    Internal.__start (Shmem.MPSTChannel.connect c ~role:"role_S1")

  module C = struct
    module Make(X:sig
        type conn
        val conn : conn Endpoint.conn_kind
        val write__1a : conn -> [>`_1a of unit data * 'p sess] -> unit io
        val read__1 : conn -> [`_1 of unit data * 'p0] io
      end) = struct
      type conn = X.conn
      let role : ([>`C of X.conn * 'lab], X.conn, 'lab) role =
        {_pack_role=(fun labels -> `C(labels)) ; _repr="role_C"; _kind=X.conn}

      let _1a : 'p. ([>`_1a of unit data * 'p sess], X.conn, unit data * 'p sess) label =
        {_pack_label=(fun payload -> `_1a(payload)); _send=X.write__1a}
      let receive__1  : type p0. ([`_1 of unit data * p0], X.conn) labels =
        {_receive=X.read__1}
    end

    module Raw = struct
      include Make(struct
          type conn = Shmem.Raw.t
          let conn = Shmem.MPSTChannel.Raw
          let write__1a = Shmem.Raw.send
          let read__1 = Shmem.Raw.receive
        end)
    end
  end
  module S2 = struct
    module Make(X:sig
        type conn
        val conn : conn Endpoint.conn_kind
        val write__2 : conn -> [>`_2 of unit data * 'p sess] -> unit io
        val read__2a : conn -> [`_2a of unit data * 'p0] io
      end) = struct
      type conn = X.conn
      let role : ([>`S2 of X.conn * 'lab], X.conn, 'lab) role =
        {_pack_role=(fun labels -> `S2(labels)) ; _repr="role_S2"; _kind=X.conn}

      let _2 : 'p. ([>`_2 of unit data * 'p sess], X.conn, unit data * 'p sess) label =
        {_pack_label=(fun payload -> `_2(payload)); _send=X.write__2}
      let receive__2a  : type p0. ([`_2a of unit data * p0], X.conn) labels =
        {_receive=X.read__2a}
    end

    module Raw = struct
      include Make(struct
          type conn = Shmem.Raw.t
          let conn = Shmem.MPSTChannel.Raw
          let write__2 = Shmem.Raw.send
          let read__2a = Shmem.Raw.receive
        end)
    end
  end
  module S3 = struct
    module Make(X:sig
        type conn
        val conn : conn Endpoint.conn_kind
        val write__3 : conn -> [>`_3 of unit data * 'p sess] -> unit io
        val read__3a : conn -> [`_3a of unit data * 'p0] io
      end) = struct
      type conn = X.conn
      let role : ([>`S3 of X.conn * 'lab], X.conn, 'lab) role =
        {_pack_role=(fun labels -> `S3(labels)) ; _repr="role_S3"; _kind=X.conn}

      let _3 : 'p. ([>`_3 of unit data * 'p sess], X.conn, unit data * 'p sess) label =
        {_pack_label=(fun payload -> `_3(payload)); _send=X.write__3}
      let receive__3a  : type p0. ([`_3a of unit data * p0], X.conn) labels =
        {_receive=X.read__3a}
    end

    module Raw = struct
      include Make(struct
          type conn = Shmem.Raw.t
          let conn = Shmem.MPSTChannel.Raw
          let write__3 = Shmem.Raw.send
          let read__3a = Shmem.Raw.receive
        end)
    end
  end

end

module S2 = struct
  let initiate_shmem : 'c. proto -> ('c, 'c, Shmem.Raw.t proto_S2 sess) monad = fun (ShmemMPSTChanenl__(c)) ->
    Internal.__start (Shmem.MPSTChannel.connect c ~role:"role_S2")

  module C = struct
    module Make(X:sig
        type conn
        val conn : conn Endpoint.conn_kind
      end) = struct
      type conn = X.conn
      let role : ([>`C of X.conn * 'lab], X.conn, 'lab) role =
        {_pack_role=(fun labels -> `C(labels)) ; _repr="role_C"; _kind=X.conn}

    end

    module Raw = struct
      include Make(struct
          type conn = Shmem.Raw.t
          let conn = Shmem.MPSTChannel.Raw
        end)
    end
  end
  module S1 = struct
    module Make(X:sig
        type conn
        val conn : conn Endpoint.conn_kind
        val write__2a : conn -> [>`_2a of unit data * 'p sess] -> unit io
        val read__2 : conn -> [`_2 of unit data * 'p0] io
      end) = struct
      type conn = X.conn
      let role : ([>`S1 of X.conn * 'lab], X.conn, 'lab) role =
        {_pack_role=(fun labels -> `S1(labels)) ; _repr="role_S1"; _kind=X.conn}

      let _2a : 'p. ([>`_2a of unit data * 'p sess], X.conn, unit data * 'p sess) label =
        {_pack_label=(fun payload -> `_2a(payload)); _send=X.write__2a}
      let receive__2  : type p0. ([`_2 of unit data * p0], X.conn) labels =
        {_receive=X.read__2}
    end

    module Raw = struct
      include Make(struct
          type conn = Shmem.Raw.t
          let conn = Shmem.MPSTChannel.Raw
          let write__2a = Shmem.Raw.send
          let read__2 = Shmem.Raw.receive
        end)
    end
  end
  module S3 = struct
    module Make(X:sig
        type conn
        val conn : conn Endpoint.conn_kind
      end) = struct
      type conn = X.conn
      let role : ([>`S3 of X.conn * 'lab], X.conn, 'lab) role =
        {_pack_role=(fun labels -> `S3(labels)) ; _repr="role_S3"; _kind=X.conn}

    end

    module Raw = struct
      include Make(struct
          type conn = Shmem.Raw.t
          let conn = Shmem.MPSTChannel.Raw
        end)
    end
  end

end

module S3 = struct
  let initiate_shmem : 'c. proto -> ('c, 'c, Shmem.Raw.t proto_S3 sess) monad = fun (ShmemMPSTChanenl__(c)) ->
    Internal.__start (Shmem.MPSTChannel.connect c ~role:"role_S3")

  module C = struct
    module Make(X:sig
        type conn
        val conn : conn Endpoint.conn_kind
      end) = struct
      type conn = X.conn
      let role : ([>`C of X.conn * 'lab], X.conn, 'lab) role =
        {_pack_role=(fun labels -> `C(labels)) ; _repr="role_C"; _kind=X.conn}

    end

    module Raw = struct
      include Make(struct
          type conn = Shmem.Raw.t
          let conn = Shmem.MPSTChannel.Raw
        end)
    end
  end
  module S1 = struct
    module Make(X:sig
        type conn
        val conn : conn Endpoint.conn_kind
        val write__3a : conn -> [>`_3a of unit data * 'p sess] -> unit io
        val read__3 : conn -> [`_3 of unit data * 'p0] io
      end) = struct
      type conn = X.conn
      let role : ([>`S1 of X.conn * 'lab], X.conn, 'lab) role =
        {_pack_role=(fun labels -> `S1(labels)) ; _repr="role_S1"; _kind=X.conn}

      let _3a : 'p. ([>`_3a of unit data * 'p sess], X.conn, unit data * 'p sess) label =
        {_pack_label=(fun payload -> `_3a(payload)); _send=X.write__3a}
      let receive__3  : type p0. ([`_3 of unit data * p0], X.conn) labels =
        {_receive=X.read__3}
    end

    module Raw = struct
      include Make(struct
          type conn = Shmem.Raw.t
          let conn = Shmem.MPSTChannel.Raw
          let write__3a = Shmem.Raw.send
          let read__3 = Shmem.Raw.receive
        end)
    end
  end
  module S2 = struct
    module Make(X:sig
        type conn
        val conn : conn Endpoint.conn_kind
      end) = struct
      type conn = X.conn
      let role : ([>`S2 of X.conn * 'lab], X.conn, 'lab) role =
        {_pack_role=(fun labels -> `S2(labels)) ; _repr="role_S2"; _kind=X.conn}

    end

    module Raw = struct
      include Make(struct
          type conn = Shmem.Raw.t
          let conn = Shmem.MPSTChannel.Raw
        end)
    end
  end

end

end