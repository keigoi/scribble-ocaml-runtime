(* Generated from scribble-ocaml https://github.com/keigoi/scribble-ocaml
 * This code should be compiled with scribble-ocaml-runtime
 * https://github.com/keigoi/scribble-ocaml-runtime *)


module Make (Session:Scribble.S.SESSION)  = struct


open Session

type ('c_S) game2Proto_C = ('c_S) game2Proto_C_1
and ('c_S) game2Proto_C_1 =
  [`recv of [`S of 'c_S *
    [`playAsA of Game.game_A sess *
      [`close] sess
    |`playAsB of Game.game_B sess *
      [`close] sess
    |`playAsC of Game.game_C sess *
      [`close] sess]]]
type ('c_C) game2Proto_S = ('c_C) game2Proto_S_1
and ('c_C) game2Proto_S_1 =
  [`send of [`C of 'c_C *
    [`playAsA of Game.game_A sess *
      [`close] sess
    |`playAsB of Game.game_B sess *
      [`close] sess
    |`playAsC of Game.game_C sess *
      [`close] sess]]]


module Shmem = Scribble.Shmem.Make(Session.LinIO.IO)(Session.Mutex)(Session.Condition)(Session.Endpoint)

type game2Proto = ShmemMPSTChanenl__ of Shmem.MPSTChannel.t
let create_shmem_channel : unit -> game2Proto = fun () ->
  ShmemMPSTChanenl__(Shmem.MPSTChannel.create ~acceptor_role:"role_C" ~connector_roles:["role_S";])


module C = struct
  let initiate_shmem : 'c. game2Proto -> ('c, 'c, Shmem.Raw.t game2Proto_C sess) monad = fun (ShmemMPSTChanenl__(c)) ->
    Internal.__start (Shmem.MPSTChannel.accept c ~role:"role_C")

  module S = struct
    module Make(X:sig
        type conn
        val conn : conn Endpoint.conn_kind
        val read_playAsA_or_playAsB_or_playAsC : conn -> [`playAsA of Game.game_A sess * 'p0|`playAsB of Game.game_B sess * 'p1|`playAsC of Game.game_C sess * 'p2] io
      end) = struct
      type conn = X.conn
      let role : ([>`S of X.conn * 'lab], X.conn, 'lab) role =
        {_pack_role=(fun labels -> `S(labels)) ; _repr="role_S"; _kind=X.conn}

      let receive_playAsA_or_playAsB_or_playAsC  : type p0 p1 p2. ([`playAsA of Game.game_A sess * p0|`playAsB of Game.game_B sess * p1|`playAsC of Game.game_C sess * p2], X.conn) labels =
        {_receive=X.read_playAsA_or_playAsB_or_playAsC}
    end

    module Raw = struct
      include Make(struct
          type conn = Shmem.Raw.t
          let conn = Shmem.MPSTChannel.Raw
          let read_playAsA_or_playAsB_or_playAsC = Shmem.Raw.receive
        end)
    end
  end

end

module S = struct
  let initiate_shmem : 'c. game2Proto -> ('c, 'c, Shmem.Raw.t game2Proto_S sess) monad = fun (ShmemMPSTChanenl__(c)) ->
    Internal.__start (Shmem.MPSTChannel.connect c ~role:"role_S")

  module C = struct
    module Make(X:sig
        type conn
        val conn : conn Endpoint.conn_kind
        val write_playAsA : conn -> [>`playAsA of Game.game_A sess * 'p sess] -> unit io
        val write_playAsB : conn -> [>`playAsB of Game.game_B sess * 'p sess] -> unit io
        val write_playAsC : conn -> [>`playAsC of Game.game_C sess * 'p sess] -> unit io
      end) = struct
      type conn = X.conn
      let role : ([>`C of X.conn * 'lab], X.conn, 'lab) role =
        {_pack_role=(fun labels -> `C(labels)) ; _repr="role_C"; _kind=X.conn}

      let playAsA : 'p. ([>`playAsA of Game.game_A sess * 'p sess], X.conn, Game.game_A sess * 'p sess) label =
        {_pack_label=(fun payload -> `playAsA(payload)); _send=X.write_playAsA}
      let playAsB : 'p. ([>`playAsB of Game.game_B sess * 'p sess], X.conn, Game.game_B sess * 'p sess) label =
        {_pack_label=(fun payload -> `playAsB(payload)); _send=X.write_playAsB}
      let playAsC : 'p. ([>`playAsC of Game.game_C sess * 'p sess], X.conn, Game.game_C sess * 'p sess) label =
        {_pack_label=(fun payload -> `playAsC(payload)); _send=X.write_playAsC}
    end

    module Raw = struct
      include Make(struct
          type conn = Shmem.Raw.t
          let conn = Shmem.MPSTChannel.Raw
          let write_playAsA = Shmem.Raw.send
          let write_playAsB = Shmem.Raw.send
          let write_playAsC = Shmem.Raw.send
        end)
    end
  end

end

end