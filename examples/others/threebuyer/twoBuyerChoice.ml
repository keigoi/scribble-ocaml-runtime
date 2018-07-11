(* Generated from scribble-ocaml https://github.com/keigoi/scribble-ocaml
 * This code should be compiled with scribble-ocaml-runtime
 * https://github.com/keigoi/scribble-ocaml-runtime *)


module Make (Session:Scribble.S.SESSION)  = struct
  type string = java.lang.String
  type date = test.twobuyer.Date

open Session

type ('c_B, 'c_S) twoBuyerChoice_A = ('c_B, 'c_S) twoBuyerChoice_A_1
and ('c_B, 'c_S) twoBuyerChoice_A_1 =
  [`recv of [`B of 'c_B *
    [`ok of string data *
      [`close] sess
    |`quit of unit data *
      [`close] sess]]]
type ('c_A, 'c_S) twoBuyerChoice_B = ('c_A, 'c_S) twoBuyerChoice_B_1
and ('c_A, 'c_S) twoBuyerChoice_B_1 =
  [`send of [`A of 'c_A *
    [`ok of string data *
      [`send of [`S of 'c_S * [`ok of string data *
        [`recv of [`S of 'c_S * [`msg of date data *
          [`close] sess]]] sess]]] sess
    |`quit of unit data *
      [`send of [`S of 'c_S * [`quit of unit data *
        [`close] sess]]] sess]]]
type ('c_A, 'c_B) twoBuyerChoice_S = ('c_A, 'c_B) twoBuyerChoice_S_1
and ('c_A, 'c_B) twoBuyerChoice_S_1 =
  [`recv of [`B of 'c_B *
    [`ok of string data *
      [`send of [`B of 'c_B * [`msg of date data *
        [`close] sess]]] sess
    |`quit of unit data *
      [`close] sess]]]


module Shmem = Scribble.Shmem.Make(Session.LinIO.IO)(Session.Mutex)(Session.Condition)(Session.Endpoint)

type twoBuyerChoice = ShmemMPSTChanenl__ of Shmem.MPSTChannel.t
let create_shmem_channel : unit -> twoBuyerChoice = fun () ->
  ShmemMPSTChanenl__(Shmem.MPSTChannel.create ~acceptor_role:"role_A" ~connector_roles:["role_B";; "role_S"])


module A = struct
  let initiate_shmem : 'c. twoBuyerChoice -> ('c, 'c, Shmem.Raw.t twoBuyerChoice_A sess) monad = fun (ShmemMPSTChanenl__(c)) ->
    Internal.__start (Shmem.MPSTChannel.accept c ~role:"role_A")

  module B = struct
    module Make(X:sig
        type conn
        val conn : conn Endpoint.conn_kind
        val read_ok_or_quit : conn -> [`ok of string data * 'p0|`quit of unit data * 'p1] io
      end) = struct
      type conn = X.conn
      let role : ([>`B of X.conn * 'lab], X.conn, 'lab) role =
        {_pack_role=(fun labels -> `B(labels)) ; _repr="role_B"; _kind=X.conn}

      let receive_ok_or_quit  : type p0 p1. ([`ok of string data * p0|`quit of unit data * p1], X.conn) labels =
        {_receive=X.read_ok_or_quit}
    end

    module Raw = struct
      include Make(struct
          type conn = Shmem.Raw.t
          let conn = Shmem.MPSTChannel.Raw
          let read_ok_or_quit = Shmem.Raw.receive
        end)
    end
  end
  module S = struct
    module Make(X:sig
        type conn
        val conn : conn Endpoint.conn_kind
      end) = struct
      type conn = X.conn
      let role : ([>`S of X.conn * 'lab], X.conn, 'lab) role =
        {_pack_role=(fun labels -> `S(labels)) ; _repr="role_S"; _kind=X.conn}

    end

    module Raw = struct
      include Make(struct
          type conn = Shmem.Raw.t
          let conn = Shmem.MPSTChannel.Raw
        end)
    end
  end

end

module B = struct
  let initiate_shmem : 'c. twoBuyerChoice -> ('c, 'c, Shmem.Raw.t twoBuyerChoice_B sess) monad = fun (ShmemMPSTChanenl__(c)) ->
    Internal.__start (Shmem.MPSTChannel.connect c ~role:"role_B")

  module A = struct
    module Make(X:sig
        type conn
        val conn : conn Endpoint.conn_kind
        val write_ok : conn -> [>`ok of string data * 'p sess] -> unit io
        val write_quit : conn -> [>`quit of unit data * 'p sess] -> unit io
      end) = struct
      type conn = X.conn
      let role : ([>`A of X.conn * 'lab], X.conn, 'lab) role =
        {_pack_role=(fun labels -> `A(labels)) ; _repr="role_A"; _kind=X.conn}

      let ok : 'p. ([>`ok of string data * 'p sess], X.conn, string data * 'p sess) label =
        {_pack_label=(fun payload -> `ok(payload)); _send=X.write_ok}
      let quit : 'p. ([>`quit of unit data * 'p sess], X.conn, unit data * 'p sess) label =
        {_pack_label=(fun payload -> `quit(payload)); _send=X.write_quit}
    end

    module Raw = struct
      include Make(struct
          type conn = Shmem.Raw.t
          let conn = Shmem.MPSTChannel.Raw
          let write_ok = Shmem.Raw.send
          let write_quit = Shmem.Raw.send
        end)
    end
  end
  module S = struct
    module Make(X:sig
        type conn
        val conn : conn Endpoint.conn_kind
        val write_ok : conn -> [>`ok of string data * 'p sess] -> unit io
        val write_quit : conn -> [>`quit of unit data * 'p sess] -> unit io
        val read_msg : conn -> [`msg of date data * 'p0] io
      end) = struct
      type conn = X.conn
      let role : ([>`S of X.conn * 'lab], X.conn, 'lab) role =
        {_pack_role=(fun labels -> `S(labels)) ; _repr="role_S"; _kind=X.conn}

      let ok : 'p. ([>`ok of string data * 'p sess], X.conn, string data * 'p sess) label =
        {_pack_label=(fun payload -> `ok(payload)); _send=X.write_ok}
      let quit : 'p. ([>`quit of unit data * 'p sess], X.conn, unit data * 'p sess) label =
        {_pack_label=(fun payload -> `quit(payload)); _send=X.write_quit}
      let receive_msg  : type p0. ([`msg of date data * p0], X.conn) labels =
        {_receive=X.read_msg}
    end

    module Raw = struct
      include Make(struct
          type conn = Shmem.Raw.t
          let conn = Shmem.MPSTChannel.Raw
          let write_ok = Shmem.Raw.send
          let write_quit = Shmem.Raw.send
          let read_msg = Shmem.Raw.receive
        end)
    end
  end

end

module S = struct
  let initiate_shmem : 'c. twoBuyerChoice -> ('c, 'c, Shmem.Raw.t twoBuyerChoice_S sess) monad = fun (ShmemMPSTChanenl__(c)) ->
    Internal.__start (Shmem.MPSTChannel.connect c ~role:"role_S")

  module A = struct
    module Make(X:sig
        type conn
        val conn : conn Endpoint.conn_kind
      end) = struct
      type conn = X.conn
      let role : ([>`A of X.conn * 'lab], X.conn, 'lab) role =
        {_pack_role=(fun labels -> `A(labels)) ; _repr="role_A"; _kind=X.conn}

    end

    module Raw = struct
      include Make(struct
          type conn = Shmem.Raw.t
          let conn = Shmem.MPSTChannel.Raw
        end)
    end
  end
  module B = struct
    module Make(X:sig
        type conn
        val conn : conn Endpoint.conn_kind
        val write_msg : conn -> [>`msg of date data * 'p sess] -> unit io
        val read_ok_or_quit : conn -> [`ok of string data * 'p0|`quit of unit data * 'p1] io
      end) = struct
      type conn = X.conn
      let role : ([>`B of X.conn * 'lab], X.conn, 'lab) role =
        {_pack_role=(fun labels -> `B(labels)) ; _repr="role_B"; _kind=X.conn}

      let msg : 'p. ([>`msg of date data * 'p sess], X.conn, date data * 'p sess) label =
        {_pack_label=(fun payload -> `msg(payload)); _send=X.write_msg}
      let receive_ok_or_quit  : type p0 p1. ([`ok of string data * p0|`quit of unit data * p1], X.conn) labels =
        {_receive=X.read_ok_or_quit}
    end

    module Raw = struct
      include Make(struct
          type conn = Shmem.Raw.t
          let conn = Shmem.MPSTChannel.Raw
          let write_msg = Shmem.Raw.send
          let read_ok_or_quit = Shmem.Raw.receive
        end)
    end
  end

end

end