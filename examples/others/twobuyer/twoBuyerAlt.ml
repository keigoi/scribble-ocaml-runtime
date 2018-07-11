(* Generated from scribble-ocaml https://github.com/keigoi/scribble-ocaml
 * This code should be compiled with scribble-ocaml-runtime
 * https://github.com/keigoi/scribble-ocaml-runtime *)


module Make (Session:Scribble.S.SESSION)  = struct
  type date = string

open Session

type ('c_B, 'c_S) twoBuyerAlt_A = ('c_B, 'c_S) twoBuyerAlt_A_1
and ('c_B, 'c_S) twoBuyerAlt_A_1 =
  [`send of [`S of 'c_S * [`buy of string data *
  [`recv of [`S of 'c_S * [`amount of int data *
  [`send of [`B of 'c_B * [`ask of int data *
  [`recv of [`B of 'c_B *
    [`again of unit data *
      ('c_B, 'c_S) twoBuyerAlt_A_2 sess
    |`ok of unit data *
      [`recv of [`S of 'c_S * [`msg of date data *
      [`close] sess]]] sess
    |`quit of unit data *
      [`close] sess]]] sess]]] sess]]] sess]]]
and ('c_B, 'c_S) twoBuyerAlt_A_2 =
  [`send of [`B of 'c_B * [`ask of int data *
  [`recv of [`B of 'c_B *
    [`again of unit data *
      ('c_B, 'c_S) twoBuyerAlt_A_2 sess
    |`ok of unit data *
      [`recv of [`S of 'c_S * [`msg of date data *
      [`close] sess]]] sess
    |`quit of unit data *
      [`close] sess]]] sess]]]
type ('c_A, 'c_S) twoBuyerAlt_B = ('c_A, 'c_S) twoBuyerAlt_B_1
and ('c_A, 'c_S) twoBuyerAlt_B_1 =
  [`recv of [`A of 'c_A * [`ask of int data *
  [`send of
    [`A of 'c_A *
      [`again of unit data *
        ('c_A, 'c_S) twoBuyerAlt_B_1 sess
      |`ok of unit data *
        [`send of [`S of 'c_S * [`ok of int data *
        [`close] sess]]] sess
    |`S of 'c_S * [`quit of unit data *
      [`send of [`A of 'c_A * [`quit of unit data *
      [`close] sess]]] sess]]] sess]]]]
type ('c_A, 'c_B) twoBuyerAlt_S = ('c_A, 'c_B) twoBuyerAlt_S_1
and ('c_A, 'c_B) twoBuyerAlt_S_1 =
  [`recv of [`A of 'c_A * [`buy of string data *
  [`send of [`A of 'c_A * [`amount of int data *
  [`recv of [`B of 'c_B *
    [`ok of int data *
      [`send of [`A of 'c_A * [`msg of date data *
      [`close] sess]]] sess
    |`quit of unit data *
      [`close] sess]]] sess]]] sess]]]


module Shmem = Scribble.Shmem.Make(Session.LinIO.IO)(Session.Mutex)(Session.Condition)(Session.Endpoint)

type twoBuyerAlt = ShmemMPSTChanenl__ of Shmem.MPSTChannel.t
let create_shmem_channel : unit -> twoBuyerAlt = fun () ->
  ShmemMPSTChanenl__(Shmem.MPSTChannel.create ~acceptor_role:"role_A" ~connector_roles:["role_B"; "role_S"])


module A = struct
  let initiate_shmem : 'c. twoBuyerAlt -> ('c, 'c, (Shmem.Raw.t, Shmem.Raw.t) twoBuyerAlt_A sess) monad = fun (ShmemMPSTChanenl__(c)) ->
    Internal.__start (Shmem.MPSTChannel.accept c ~role:"role_A")

  module B = struct
    module Make(X:sig
        type conn
        val conn : conn Endpoint.conn_kind
        val write_ask : conn -> [>`ask of int data * 'p sess] -> unit io
        val read_again_or_ok_or_quit : conn -> [`again of unit data * 'p0|`ok of unit data * 'p1|`quit of unit data * 'p2] io
      end) = struct
      type conn = X.conn
      let role : ([>`B of X.conn * 'lab], X.conn, 'lab) role =
        {_pack_role=(fun labels -> `B(labels)) ; _repr="role_B"; _kind=X.conn}

      let ask : 'p. ([>`ask of int data * 'p sess], X.conn, int data * 'p sess) label =
        {_pack_label=(fun payload -> `ask(payload)); _send=X.write_ask}
      let receive_again_or_ok_or_quit  : type p0 p1 p2. ([`again of unit data * p0|`ok of unit data * p1|`quit of unit data * p2], X.conn) labels =
        {_receive=X.read_again_or_ok_or_quit}
    end

    module Raw = struct
      include Make(struct
          type conn = Shmem.Raw.t
          let conn = Shmem.MPSTChannel.Raw
          let write_ask = Shmem.Raw.send
          let read_again_or_ok_or_quit = Shmem.Raw.receive
        end)
    end
  end
  module S = struct
    module Make(X:sig
        type conn
        val conn : conn Endpoint.conn_kind
        val write_buy : conn -> [>`buy of string data * 'p sess] -> unit io
        val read_amount : conn -> [`amount of int data * 'p0] io
        val read_msg : conn -> [`msg of date data * 'p0] io
      end) = struct
      type conn = X.conn
      let role : ([>`S of X.conn * 'lab], X.conn, 'lab) role =
        {_pack_role=(fun labels -> `S(labels)) ; _repr="role_S"; _kind=X.conn}

      let buy : 'p. ([>`buy of string data * 'p sess], X.conn, string data * 'p sess) label =
        {_pack_label=(fun payload -> `buy(payload)); _send=X.write_buy}
      let receive_amount  : type p0. ([`amount of int data * p0], X.conn) labels =
        {_receive=X.read_amount}
      let receive_msg  : type p0. ([`msg of date data * p0], X.conn) labels =
        {_receive=X.read_msg}
    end

    module Raw = struct
      include Make(struct
          type conn = Shmem.Raw.t
          let conn = Shmem.MPSTChannel.Raw
          let write_buy = Shmem.Raw.send
          let read_amount = Shmem.Raw.receive
          let read_msg = Shmem.Raw.receive
        end)
    end
  end

end

module B = struct
  let initiate_shmem : 'c. twoBuyerAlt -> ('c, 'c, (Shmem.Raw.t, Shmem.Raw.t) twoBuyerAlt_B sess) monad = fun (ShmemMPSTChanenl__(c)) ->
    Internal.__start (Shmem.MPSTChannel.connect c ~role:"role_B")

  module A = struct
    module Make(X:sig
        type conn
        val conn : conn Endpoint.conn_kind
        val write_again : conn -> [>`again of unit data * 'p sess] -> unit io
        val write_ok : conn -> [>`ok of unit data * 'p sess] -> unit io
        val write_quit : conn -> [>`quit of unit data * 'p sess] -> unit io
        val read_ask : conn -> [`ask of int data * 'p0] io
      end) = struct
      type conn = X.conn
      let role : ([>`A of X.conn * 'lab], X.conn, 'lab) role =
        {_pack_role=(fun labels -> `A(labels)) ; _repr="role_A"; _kind=X.conn}

      let again : 'p. ([>`again of unit data * 'p sess], X.conn, unit data * 'p sess) label =
        {_pack_label=(fun payload -> `again(payload)); _send=X.write_again}
      let ok : 'p. ([>`ok of unit data * 'p sess], X.conn, unit data * 'p sess) label =
        {_pack_label=(fun payload -> `ok(payload)); _send=X.write_ok}
      let quit : 'p. ([>`quit of unit data * 'p sess], X.conn, unit data * 'p sess) label =
        {_pack_label=(fun payload -> `quit(payload)); _send=X.write_quit}
      let receive_ask  : type p0. ([`ask of int data * p0], X.conn) labels =
        {_receive=X.read_ask}
    end

    module Raw = struct
      include Make(struct
          type conn = Shmem.Raw.t
          let conn = Shmem.MPSTChannel.Raw
          let write_again = Shmem.Raw.send
          let write_ok = Shmem.Raw.send
          let write_quit = Shmem.Raw.send
          let read_ask = Shmem.Raw.receive
        end)
    end
  end
  module S = struct
    module Make(X:sig
        type conn
        val conn : conn Endpoint.conn_kind
        val write_quit : conn -> [>`quit of unit data * 'p sess] -> unit io
        val write_ok : conn -> [>`ok of int data * 'p sess] -> unit io
      end) = struct
      type conn = X.conn
      let role : ([>`S of X.conn * 'lab], X.conn, 'lab) role =
        {_pack_role=(fun labels -> `S(labels)) ; _repr="role_S"; _kind=X.conn}

      let quit : 'p. ([>`quit of unit data * 'p sess], X.conn, unit data * 'p sess) label =
        {_pack_label=(fun payload -> `quit(payload)); _send=X.write_quit}
      let ok : 'p. ([>`ok of int data * 'p sess], X.conn, int data * 'p sess) label =
        {_pack_label=(fun payload -> `ok(payload)); _send=X.write_ok}
    end

    module Raw = struct
      include Make(struct
          type conn = Shmem.Raw.t
          let conn = Shmem.MPSTChannel.Raw
          let write_quit = Shmem.Raw.send
          let write_ok = Shmem.Raw.send
        end)
    end
  end

end

module S = struct
  let initiate_shmem : 'c. twoBuyerAlt -> ('c, 'c, (Shmem.Raw.t, Shmem.Raw.t) twoBuyerAlt_S sess) monad = fun (ShmemMPSTChanenl__(c)) ->
    Internal.__start (Shmem.MPSTChannel.connect c ~role:"role_S")

  module A = struct
    module Make(X:sig
        type conn
        val conn : conn Endpoint.conn_kind
        val write_amount : conn -> [>`amount of int data * 'p sess] -> unit io
        val write_msg : conn -> [>`msg of date data * 'p sess] -> unit io
        val read_buy : conn -> [`buy of string data * 'p0] io
      end) = struct
      type conn = X.conn
      let role : ([>`A of X.conn * 'lab], X.conn, 'lab) role =
        {_pack_role=(fun labels -> `A(labels)) ; _repr="role_A"; _kind=X.conn}

      let amount : 'p. ([>`amount of int data * 'p sess], X.conn, int data * 'p sess) label =
        {_pack_label=(fun payload -> `amount(payload)); _send=X.write_amount}
      let msg : 'p. ([>`msg of date data * 'p sess], X.conn, date data * 'p sess) label =
        {_pack_label=(fun payload -> `msg(payload)); _send=X.write_msg}
      let receive_buy  : type p0. ([`buy of string data * p0], X.conn) labels =
        {_receive=X.read_buy}
    end

    module Raw = struct
      include Make(struct
          type conn = Shmem.Raw.t
          let conn = Shmem.MPSTChannel.Raw
          let write_amount = Shmem.Raw.send
          let write_msg = Shmem.Raw.send
          let read_buy = Shmem.Raw.receive
        end)
    end
  end
  module B = struct
    module Make(X:sig
        type conn
        val conn : conn Endpoint.conn_kind
        val read_ok_or_quit : conn -> [`ok of int data * 'p0|`quit of unit data * 'p1] io
      end) = struct
      type conn = X.conn
      let role : ([>`B of X.conn * 'lab], X.conn, 'lab) role =
        {_pack_role=(fun labels -> `B(labels)) ; _repr="role_B"; _kind=X.conn}

      let receive_ok_or_quit  : type p0 p1. ([`ok of int data * p0|`quit of unit data * p1], X.conn) labels =
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

end

end
