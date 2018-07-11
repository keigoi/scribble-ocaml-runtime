(* Generated from scribble-ocaml https://github.com/keigoi/scribble-ocaml
 * This code should be compiled with scribble-ocaml-runtime
 * https://github.com/keigoi/scribble-ocaml-runtime *)


module Make (Session:Scribble.S.SESSION)  = struct
  type int = java.lang.Integer

open Session

type ('c_B) threeBuyer_C = ('c_B) threeBuyer_C_1
and ('c_B) threeBuyer_C_1 =
  [`recv of [`B of 'c_B * [`msg of int data *
    [`recv of [`B of 'c_B * [`msg of TwoBuyerChoice.twoBuyerChoice_B sess *
      [`send of [`B of 'c_B *
        [`ok of unit data *
          [`close] sess
        |`quit of unit data *
          [`close] sess]]] sess]]] sess]]]
type ('c_C) threeBuyer_B = ('c_C) threeBuyer_B_1
and ('c_C) threeBuyer_B_1 =
  [`send of [`C of 'c_C * [`msg of int data *
    [`send of [`C of 'c_C * [`msg of TwoBuyerChoice.twoBuyerChoice_B sess *
      [`recv of [`C of 'c_C *
        [`ok of unit data *
          [`close] sess
        |`quit of unit data *
          [`close] sess]]] sess]]] sess]]]


module Shmem = Scribble.Shmem.Make(Session.LinIO.IO)(Session.Mutex)(Session.Condition)(Session.Endpoint)

type threeBuyer = ShmemMPSTChanenl__ of Shmem.MPSTChannel.t
let create_shmem_channel : unit -> threeBuyer = fun () ->
  ShmemMPSTChanenl__(Shmem.MPSTChannel.create ~acceptor_role:"role_C" ~connector_roles:["role_B";])


module C = struct
  let initiate_shmem : 'c. threeBuyer -> ('c, 'c, Shmem.Raw.t threeBuyer_C sess) monad = fun (ShmemMPSTChanenl__(c)) ->
    Internal.__start (Shmem.MPSTChannel.accept c ~role:"role_C")

  module B = struct
    module Make(X:sig
        type conn
        val conn : conn Endpoint.conn_kind
        val write_ok : conn -> [>`ok of unit data * 'p sess] -> unit io
        val write_quit : conn -> [>`quit of unit data * 'p sess] -> unit io
        val read_msg : conn -> [`msg of int data * 'p0] io
        val read_msg_1 : conn -> [`msg of TwoBuyerChoice.twoBuyerChoice_B sess * 'p0] io
      end) = struct
      type conn = X.conn
      let role : ([>`B of X.conn * 'lab], X.conn, 'lab) role =
        {_pack_role=(fun labels -> `B(labels)) ; _repr="role_B"; _kind=X.conn}

      let ok : 'p. ([>`ok of unit data * 'p sess], X.conn, unit data * 'p sess) label =
        {_pack_label=(fun payload -> `ok(payload)); _send=X.write_ok}
      let quit : 'p. ([>`quit of unit data * 'p sess], X.conn, unit data * 'p sess) label =
        {_pack_label=(fun payload -> `quit(payload)); _send=X.write_quit}
      let receive_msg  : type p0. ([`msg of int data * p0], X.conn) labels =
        {_receive=X.read_msg}
      let receive_msg_1  : type p0. ([`msg of TwoBuyerChoice.twoBuyerChoice_B sess * p0], X.conn) labels =
        {_receive=X.read_msg_1}
    end

    module Raw = struct
      include Make(struct
          type conn = Shmem.Raw.t
          let conn = Shmem.MPSTChannel.Raw
          let write_ok = Shmem.Raw.send
          let write_quit = Shmem.Raw.send
          let read_msg = Shmem.Raw.receive
          let read_msg_1 = Shmem.Raw.receive
        end)
    end
  end

end

module B = struct
  let initiate_shmem : 'c. threeBuyer -> ('c, 'c, Shmem.Raw.t threeBuyer_B sess) monad = fun (ShmemMPSTChanenl__(c)) ->
    Internal.__start (Shmem.MPSTChannel.connect c ~role:"role_B")

  module C = struct
    module Make(X:sig
        type conn
        val conn : conn Endpoint.conn_kind
        val write_msg : conn -> [>`msg of int data * 'p sess] -> unit io
        val write_msg_1 : conn -> [>`msg of TwoBuyerChoice.twoBuyerChoice_B sess * 'p sess] -> unit io
        val read_ok_or_quit : conn -> [`ok of unit data * 'p0|`quit of unit data * 'p1] io
      end) = struct
      type conn = X.conn
      let role : ([>`C of X.conn * 'lab], X.conn, 'lab) role =
        {_pack_role=(fun labels -> `C(labels)) ; _repr="role_C"; _kind=X.conn}

      let msg : 'p. ([>`msg of int data * 'p sess], X.conn, int data * 'p sess) label =
        {_pack_label=(fun payload -> `msg(payload)); _send=X.write_msg}
      let msg_1 : 'p. ([>`msg of TwoBuyerChoice.twoBuyerChoice_B sess * 'p sess], X.conn, TwoBuyerChoice.twoBuyerChoice_B sess * 'p sess) label =
        {_pack_label=(fun payload -> `msg(payload)); _send=X.write_msg_1}
      let receive_ok_or_quit  : type p0 p1. ([`ok of unit data * p0|`quit of unit data * p1], X.conn) labels =
        {_receive=X.read_ok_or_quit}
    end

    module Raw = struct
      include Make(struct
          type conn = Shmem.Raw.t
          let conn = Shmem.MPSTChannel.Raw
          let write_msg = Shmem.Raw.send
          let write_msg_1 = Shmem.Raw.send
          let read_ok_or_quit = Shmem.Raw.receive
        end)
    end
  end

end

end