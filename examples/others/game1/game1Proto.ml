(* Generated from scribble-ocaml https://github.com/keigoi/scribble-ocaml
 * This code should be compiled with scribble-ocaml-runtime
 * https://github.com/keigoi/scribble-ocaml-runtime *)


module Make (Session:Scribble.S.SESSION)  = struct


open Session

type ('c_S1, 'c_S2) game1Proto_Client = ('c_S1, 'c_S2) game1Proto_Client_1
and ('c_S1, 'c_S2) game1Proto_Client_1 =
  [`recv of [`S1 of 'c_S1 *
    [`playAsA of unit data *
      ('c_S1, 'c_S2) game1Proto_Client_2 sess
    |`playAsB of Game.game_B sess *
      [`close] sess
    |`playAsC of Game.game_C sess *
      [`close] sess]]]
and ('c_S1, 'c_S2) game1Proto_Client_2 =
  [`send of [`S1 of 'c_S1 *
    [`_1 of unit data *
      [`recv of [`S2 of 'c_S2 * [`_1 of unit data *
        ('c_S1, 'c_S2) game1Proto_Client_2 sess]]] sess
    |`_2 of unit data *
      [`recv of [`S2 of 'c_S2 * [`_2 of unit data *
        [`close] sess]]] sess]]]
type ('c_Client, 'c_S2) game1Proto_S1 = ('c_Client, 'c_S2) game1Proto_S1_1
and ('c_Client, 'c_S2) game1Proto_S1_1 =
  [`send of [`Client of 'c_Client *
    [`playAsA of unit data *
      ('c_Client, 'c_S2) game1Proto_S1_2 sess
    |`playAsB of Game.game_B sess *
      [`send of [`S2 of 'c_S2 * [`fin of unit data *
        [`close] sess]]] sess
    |`playAsC of Game.game_C sess *
      [`send of [`S2 of 'c_S2 * [`fin of unit data *
        [`close] sess]]] sess]]]
and ('c_Client, 'c_S2) game1Proto_S1_2 =
  [`recv of [`Client of 'c_Client *
    [`_1 of unit data *
      [`send of [`S2 of 'c_S2 * [`_1 of unit data *
        ('c_Client, 'c_S2) game1Proto_S1_2 sess]]] sess
    |`_2 of unit data *
      [`send of [`S2 of 'c_S2 * [`_2 of unit data *
        [`close] sess]]] sess]]]
type ('c_Client, 'c_S1) game1Proto_S2 = ('c_Client, 'c_S1) game1Proto_S2_1
and ('c_Client, 'c_S1) game1Proto_S2_1 =
  [`recv of [`S1 of 'c_S1 *
    [`_1 of unit data *
      [`send of [`Client of 'c_Client * [`_1 of unit data *
        ('c_Client, 'c_S1) game1Proto_S2_2 sess]]] sess
    |`_2 of unit data *
      [`send of [`Client of 'c_Client * [`_2 of unit data *
        [`close] sess]]] sess
    |`fin of unit data *
      [`close] sess]]]
and ('c_Client, 'c_S1) game1Proto_S2_2 =
  [`recv of [`S1 of 'c_S1 *
    [`_1 of unit data *
      [`send of [`Client of 'c_Client * [`_1 of unit data *
        ('c_Client, 'c_S1) game1Proto_S2_2 sess]]] sess
    |`_2 of unit data *
      [`send of [`Client of 'c_Client * [`_2 of unit data *
        [`close] sess]]] sess]]]


module Shmem = Scribble.Shmem.Make(Session.LinIO.IO)(Session.Mutex)(Session.Condition)(Session.Endpoint)

type game1Proto = ShmemMPSTChanenl__ of Shmem.MPSTChannel.t
let create_shmem_channel : unit -> game1Proto = fun () ->
  ShmemMPSTChanenl__(Shmem.MPSTChannel.create ~acceptor_role:"role_Client" ~connector_roles:["role_S1";; "role_S2"])


module Client = struct
  let initiate_shmem : 'c. game1Proto -> ('c, 'c, Shmem.Raw.t game1Proto_Client sess) monad = fun (ShmemMPSTChanenl__(c)) ->
    Internal.__start (Shmem.MPSTChannel.accept c ~role:"role_Client")

  module S1 = struct
    module Make(X:sig
        type conn
        val conn : conn Endpoint.conn_kind
        val write__1 : conn -> [>`_1 of unit data * 'p sess] -> unit io
        val write__2 : conn -> [>`_2 of unit data * 'p sess] -> unit io
        val read_playAsA_or_playAsB_or_playAsC : conn -> [`playAsA of unit data * 'p0|`playAsB of Game.game_B sess * 'p1|`playAsC of Game.game_C sess * 'p2] io
      end) = struct
      type conn = X.conn
      let role : ([>`S1 of X.conn * 'lab], X.conn, 'lab) role =
        {_pack_role=(fun labels -> `S1(labels)) ; _repr="role_S1"; _kind=X.conn}

      let _1 : 'p. ([>`_1 of unit data * 'p sess], X.conn, unit data * 'p sess) label =
        {_pack_label=(fun payload -> `_1(payload)); _send=X.write__1}
      let _2 : 'p. ([>`_2 of unit data * 'p sess], X.conn, unit data * 'p sess) label =
        {_pack_label=(fun payload -> `_2(payload)); _send=X.write__2}
      let receive_playAsA_or_playAsB_or_playAsC  : type p0 p1 p2. ([`playAsA of unit data * p0|`playAsB of Game.game_B sess * p1|`playAsC of Game.game_C sess * p2], X.conn) labels =
        {_receive=X.read_playAsA_or_playAsB_or_playAsC}
    end

    module Raw = struct
      include Make(struct
          type conn = Shmem.Raw.t
          let conn = Shmem.MPSTChannel.Raw
          let write__1 = Shmem.Raw.send
          let write__2 = Shmem.Raw.send
          let read_playAsA_or_playAsB_or_playAsC = Shmem.Raw.receive
        end)
    end
  end
  module S2 = struct
    module Make(X:sig
        type conn
        val conn : conn Endpoint.conn_kind
        val read__1 : conn -> [`_1 of unit data * 'p0] io
        val read__2 : conn -> [`_2 of unit data * 'p0] io
      end) = struct
      type conn = X.conn
      let role : ([>`S2 of X.conn * 'lab], X.conn, 'lab) role =
        {_pack_role=(fun labels -> `S2(labels)) ; _repr="role_S2"; _kind=X.conn}

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

module S1 = struct
  let initiate_shmem : 'c. game1Proto -> ('c, 'c, Shmem.Raw.t game1Proto_S1 sess) monad = fun (ShmemMPSTChanenl__(c)) ->
    Internal.__start (Shmem.MPSTChannel.connect c ~role:"role_S1")

  module Client = struct
    module Make(X:sig
        type conn
        val conn : conn Endpoint.conn_kind
        val write_playAsA : conn -> [>`playAsA of unit data * 'p sess] -> unit io
        val write_playAsB : conn -> [>`playAsB of Game.game_B sess * 'p sess] -> unit io
        val write_playAsC : conn -> [>`playAsC of Game.game_C sess * 'p sess] -> unit io
        val read__1_or__2 : conn -> [`_1 of unit data * 'p0|`_2 of unit data * 'p1] io
      end) = struct
      type conn = X.conn
      let role : ([>`Client of X.conn * 'lab], X.conn, 'lab) role =
        {_pack_role=(fun labels -> `Client(labels)) ; _repr="role_Client"; _kind=X.conn}

      let playAsA : 'p. ([>`playAsA of unit data * 'p sess], X.conn, unit data * 'p sess) label =
        {_pack_label=(fun payload -> `playAsA(payload)); _send=X.write_playAsA}
      let playAsB : 'p. ([>`playAsB of Game.game_B sess * 'p sess], X.conn, Game.game_B sess * 'p sess) label =
        {_pack_label=(fun payload -> `playAsB(payload)); _send=X.write_playAsB}
      let playAsC : 'p. ([>`playAsC of Game.game_C sess * 'p sess], X.conn, Game.game_C sess * 'p sess) label =
        {_pack_label=(fun payload -> `playAsC(payload)); _send=X.write_playAsC}
      let receive__1_or__2  : type p0 p1. ([`_1 of unit data * p0|`_2 of unit data * p1], X.conn) labels =
        {_receive=X.read__1_or__2}
    end

    module Raw = struct
      include Make(struct
          type conn = Shmem.Raw.t
          let conn = Shmem.MPSTChannel.Raw
          let write_playAsA = Shmem.Raw.send
          let write_playAsB = Shmem.Raw.send
          let write_playAsC = Shmem.Raw.send
          let read__1_or__2 = Shmem.Raw.receive
        end)
    end
  end
  module S2 = struct
    module Make(X:sig
        type conn
        val conn : conn Endpoint.conn_kind
        val write__1 : conn -> [>`_1 of unit data * 'p sess] -> unit io
        val write__2 : conn -> [>`_2 of unit data * 'p sess] -> unit io
        val write_fin : conn -> [>`fin of unit data * 'p sess] -> unit io
      end) = struct
      type conn = X.conn
      let role : ([>`S2 of X.conn * 'lab], X.conn, 'lab) role =
        {_pack_role=(fun labels -> `S2(labels)) ; _repr="role_S2"; _kind=X.conn}

      let _1 : 'p. ([>`_1 of unit data * 'p sess], X.conn, unit data * 'p sess) label =
        {_pack_label=(fun payload -> `_1(payload)); _send=X.write__1}
      let _2 : 'p. ([>`_2 of unit data * 'p sess], X.conn, unit data * 'p sess) label =
        {_pack_label=(fun payload -> `_2(payload)); _send=X.write__2}
      let fin : 'p. ([>`fin of unit data * 'p sess], X.conn, unit data * 'p sess) label =
        {_pack_label=(fun payload -> `fin(payload)); _send=X.write_fin}
    end

    module Raw = struct
      include Make(struct
          type conn = Shmem.Raw.t
          let conn = Shmem.MPSTChannel.Raw
          let write__1 = Shmem.Raw.send
          let write__2 = Shmem.Raw.send
          let write_fin = Shmem.Raw.send
        end)
    end
  end

end

module S2 = struct
  let initiate_shmem : 'c. game1Proto -> ('c, 'c, Shmem.Raw.t game1Proto_S2 sess) monad = fun (ShmemMPSTChanenl__(c)) ->
    Internal.__start (Shmem.MPSTChannel.connect c ~role:"role_S2")

  module Client = struct
    module Make(X:sig
        type conn
        val conn : conn Endpoint.conn_kind
        val write__1 : conn -> [>`_1 of unit data * 'p sess] -> unit io
        val write__2 : conn -> [>`_2 of unit data * 'p sess] -> unit io
      end) = struct
      type conn = X.conn
      let role : ([>`Client of X.conn * 'lab], X.conn, 'lab) role =
        {_pack_role=(fun labels -> `Client(labels)) ; _repr="role_Client"; _kind=X.conn}

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
  module S1 = struct
    module Make(X:sig
        type conn
        val conn : conn Endpoint.conn_kind
        val read__1_or__2_or_fin : conn -> [`_1 of unit data * 'p0|`_2 of unit data * 'p1|`fin of unit data * 'p2] io
        val read__1_or__2 : conn -> [`_1 of unit data * 'p0|`_2 of unit data * 'p1] io
      end) = struct
      type conn = X.conn
      let role : ([>`S1 of X.conn * 'lab], X.conn, 'lab) role =
        {_pack_role=(fun labels -> `S1(labels)) ; _repr="role_S1"; _kind=X.conn}

      let receive__1_or__2_or_fin  : type p0 p1 p2. ([`_1 of unit data * p0|`_2 of unit data * p1|`fin of unit data * p2], X.conn) labels =
        {_receive=X.read__1_or__2_or_fin}
      let receive__1_or__2  : type p0 p1. ([`_1 of unit data * p0|`_2 of unit data * p1], X.conn) labels =
        {_receive=X.read__1_or__2}
    end

    module Raw = struct
      include Make(struct
          type conn = Shmem.Raw.t
          let conn = Shmem.MPSTChannel.Raw
          let read__1_or__2_or_fin = Shmem.Raw.receive
          let read__1_or__2 = Shmem.Raw.receive
        end)
    end
  end

end

end