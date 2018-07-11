(* Generated from scribble-ocaml https://github.com/keigoi/scribble-ocaml
 * This code should be compiled with scribble-ocaml-runtime
 * https://github.com/keigoi/scribble-ocaml-runtime *)


module Make (Session:Scribble.S.SESSION)  = struct


open Session

type ('c_B, 'c_C) game_A = ('c_B, 'c_C) game_A_1
and ('c_B, 'c_C) game_A_1 =
  [`send of [`B of 'c_B *
    [`_1 of unit data *
      [`recv of [`C of 'c_C * [`_1 of unit data *
        ('c_B, 'c_C) game_A_1 sess]]] sess
    |`_2 of unit data *
      [`recv of [`C of 'c_C * [`_2 of unit data *
        [`close] sess]]] sess]]]
type ('c_A, 'c_C) game_B = ('c_A, 'c_C) game_B_1
and ('c_A, 'c_C) game_B_1 =
  [`recv of [`A of 'c_A *
    [`_1 of unit data *
      [`send of [`C of 'c_C * [`_1 of unit data *
        ('c_A, 'c_C) game_B_1 sess]]] sess
    |`_2 of unit data *
      [`send of [`C of 'c_C * [`_2 of unit data *
        [`close] sess]]] sess]]]
type ('c_A, 'c_B) game_C = ('c_A, 'c_B) game_C_1
and ('c_A, 'c_B) game_C_1 =
  [`recv of [`B of 'c_B *
    [`_1 of unit data *
      [`send of [`A of 'c_A * [`_1 of unit data *
        ('c_A, 'c_B) game_C_1 sess]]] sess
    |`_2 of unit data *
      [`send of [`A of 'c_A * [`_2 of unit data *
        [`close] sess]]] sess]]]


module Shmem = Scribble.Shmem.Make(Session.LinIO.IO)(Session.Mutex)(Session.Condition)(Session.Endpoint)

type game = ShmemMPSTChanenl__ of Shmem.MPSTChannel.t
let create_shmem_channel : unit -> game = fun () ->
  ShmemMPSTChanenl__(Shmem.MPSTChannel.create ~acceptor_role:"role_A" ~connector_roles:["role_B";; "role_C"])


module A = struct
  let initiate_shmem : 'c. game -> ('c, 'c, Shmem.Raw.t game_A sess) monad = fun (ShmemMPSTChanenl__(c)) ->
    Internal.__start (Shmem.MPSTChannel.accept c ~role:"role_A")

  module B = struct
    module Make(X:sig
        type conn
        val conn : conn Endpoint.conn_kind
        val write__1 : conn -> [>`_1 of unit data * 'p sess] -> unit io
        val write__2 : conn -> [>`_2 of unit data * 'p sess] -> unit io
      end) = struct
      type conn = X.conn
      let role : ([>`B of X.conn * 'lab], X.conn, 'lab) role =
        {_pack_role=(fun labels -> `B(labels)) ; _repr="role_B"; _kind=X.conn}

      let _1 : 'p. ([>`_1 of unit data * 'p sess], X.conn, unit data * 'p sess) label =
        {_pack_label=(fun payload -> `_1(payload)); _send=X.write__1}
      let _2 : 'p. ([>`_2 of unit data * 'p sess], X.conn, unit data * 'p sess) label =
        {_pack_label=(fun payload -> `_2(payload)); _send=X.write__2}
    end

    module Raw = struct
      include Make(struct
          type conn = Shmem.Raw.t
          let conn = Shmem.MPSTChannel.Raw
          let write__1 = Shmem.Raw.send
          let write__2 = Shmem.Raw.send
        end)
    end
  end
  module C = struct
    module Make(X:sig
        type conn
        val conn : conn Endpoint.conn_kind
        val read__1 : conn -> [`_1 of unit data * 'p0] io
        val read__2 : conn -> [`_2 of unit data * 'p0] io
      end) = struct
      type conn = X.conn
      let role : ([>`C of X.conn * 'lab], X.conn, 'lab) role =
        {_pack_role=(fun labels -> `C(labels)) ; _repr="role_C"; _kind=X.conn}

      let receive__1  : type p0. ([`_1 of unit data * p0], X.conn) labels =
        {_receive=X.read__1}
      let receive__2  : type p0. ([`_2 of unit data * p0], X.conn) labels =
        {_receive=X.read__2}
    end

    module Raw = struct
      include Make(struct
          type conn = Shmem.Raw.t
          let conn = Shmem.MPSTChannel.Raw
          let read__1 = Shmem.Raw.receive
          let read__2 = Shmem.Raw.receive
        end)
    end
  end

end

module B = struct
  let initiate_shmem : 'c. game -> ('c, 'c, Shmem.Raw.t game_B sess) monad = fun (ShmemMPSTChanenl__(c)) ->
    Internal.__start (Shmem.MPSTChannel.connect c ~role:"role_B")

  module A = struct
    module Make(X:sig
        type conn
        val conn : conn Endpoint.conn_kind
        val read__1_or__2 : conn -> [`_1 of unit data * 'p0|`_2 of unit data * 'p1] io
      end) = struct
      type conn = X.conn
      let role : ([>`A of X.conn * 'lab], X.conn, 'lab) role =
        {_pack_role=(fun labels -> `A(labels)) ; _repr="role_A"; _kind=X.conn}

      let receive__1_or__2  : type p0 p1. ([`_1 of unit data * p0|`_2 of unit data * p1], X.conn) labels =
        {_receive=X.read__1_or__2}
    end

    module Raw = struct
      include Make(struct
          type conn = Shmem.Raw.t
          let conn = Shmem.MPSTChannel.Raw
          let read__1_or__2 = Shmem.Raw.receive
        end)
    end
  end
  module C = struct
    module Make(X:sig
        type conn
        val conn : conn Endpoint.conn_kind
        val write__1 : conn -> [>`_1 of unit data * 'p sess] -> unit io
        val write__2 : conn -> [>`_2 of unit data * 'p sess] -> unit io
      end) = struct
      type conn = X.conn
      let role : ([>`C of X.conn * 'lab], X.conn, 'lab) role =
        {_pack_role=(fun labels -> `C(labels)) ; _repr="role_C"; _kind=X.conn}

      let _1 : 'p. ([>`_1 of unit data * 'p sess], X.conn, unit data * 'p sess) label =
        {_pack_label=(fun payload -> `_1(payload)); _send=X.write__1}
      let _2 : 'p. ([>`_2 of unit data * 'p sess], X.conn, unit data * 'p sess) label =
        {_pack_label=(fun payload -> `_2(payload)); _send=X.write__2}
    end

    module Raw = struct
      include Make(struct
          type conn = Shmem.Raw.t
          let conn = Shmem.MPSTChannel.Raw
          let write__1 = Shmem.Raw.send
          let write__2 = Shmem.Raw.send
        end)
    end
  end

end

module C = struct
  let initiate_shmem : 'c. game -> ('c, 'c, Shmem.Raw.t game_C sess) monad = fun (ShmemMPSTChanenl__(c)) ->
    Internal.__start (Shmem.MPSTChannel.connect c ~role:"role_C")

  module A = struct
    module Make(X:sig
        type conn
        val conn : conn Endpoint.conn_kind
        val write__1 : conn -> [>`_1 of unit data * 'p sess] -> unit io
        val write__2 : conn -> [>`_2 of unit data * 'p sess] -> unit io
      end) = struct
      type conn = X.conn
      let role : ([>`A of X.conn * 'lab], X.conn, 'lab) role =
        {_pack_role=(fun labels -> `A(labels)) ; _repr="role_A"; _kind=X.conn}

      let _1 : 'p. ([>`_1 of unit data * 'p sess], X.conn, unit data * 'p sess) label =
        {_pack_label=(fun payload -> `_1(payload)); _send=X.write__1}
      let _2 : 'p. ([>`_2 of unit data * 'p sess], X.conn, unit data * 'p sess) label =
        {_pack_label=(fun payload -> `_2(payload)); _send=X.write__2}
    end

    module Raw = struct
      include Make(struct
          type conn = Shmem.Raw.t
          let conn = Shmem.MPSTChannel.Raw
          let write__1 = Shmem.Raw.send
          let write__2 = Shmem.Raw.send
        end)
    end
  end
  module B = struct
    module Make(X:sig
        type conn
        val conn : conn Endpoint.conn_kind
        val read__1_or__2 : conn -> [`_1 of unit data * 'p0|`_2 of unit data * 'p1] io
      end) = struct
      type conn = X.conn
      let role : ([>`B of X.conn * 'lab], X.conn, 'lab) role =
        {_pack_role=(fun labels -> `B(labels)) ; _repr="role_B"; _kind=X.conn}

      let receive__1_or__2  : type p0 p1. ([`_1 of unit data * p0|`_2 of unit data * p1], X.conn) labels =
        {_receive=X.read__1_or__2}
    end

    module Raw = struct
      include Make(struct
          type conn = Shmem.Raw.t
          let conn = Shmem.MPSTChannel.Raw
          let read__1_or__2 = Shmem.Raw.receive
        end)
    end
  end

end

end