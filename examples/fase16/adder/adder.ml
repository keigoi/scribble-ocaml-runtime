(* Generated from scribble-ocaml https://github.com/keigoi/scribble-ocaml
 * This code should be compiled with scribble-ocaml-runtime
 * https://github.com/keigoi/scribble-ocaml-runtime *)


module Make (Session:Scribble.S.SESSION)  = struct


open Session

type ('c_S) adder_C = ('c_S) adder_C_1
and ('c_S) adder_C_1 =
  [`send of [`S of 'c_S *
    [`Add of (int * int) data *
      [`recv of [`S of 'c_S * [`Res of int data *
        ('c_S) adder_C_1 sess]]] sess
    |`Bye of unit data *
      [`recv of [`S of 'c_S * [`Bye of unit data *
        [`close] sess]]] sess]]]
type ('c_C) adder_S = ('c_C) adder_S_1
and ('c_C) adder_S_1 =
  [`recv of [`C of 'c_C *
    [`Add of (int * int) data *
      [`send of [`C of 'c_C * [`Res of int data *
        ('c_C) adder_S_1 sess]]] sess
    |`Bye of unit data *
      [`send of [`C of 'c_C * [`Bye of unit data *
        [`close] sess]]] sess]]]


module Shmem = Scribble.Shmem.Make(Session.LinIO.IO)(Session.Mutex)(Session.Condition)(Session.Endpoint)

type adder = ShmemMPSTChanenl__ of Shmem.MPSTChannel.t
let create_shmem_channel : unit -> adder = fun () ->
  ShmemMPSTChanenl__(Shmem.MPSTChannel.create ~acceptor_role:"role_C" ~connector_roles:["role_S";])


module C = struct
  let initiate_shmem : 'c. adder -> ('c, 'c, Shmem.Raw.t adder_C sess) monad = fun (ShmemMPSTChanenl__(c)) ->
    Internal.__start (Shmem.MPSTChannel.accept c ~role:"role_C")

  module S = struct
    module Make(X:sig
        type conn
        val conn : conn Endpoint.conn_kind
        val write_add : conn -> [>`Add of (int * int) data * 'p sess] -> unit io
        val write_bye : conn -> [>`Bye of unit data * 'p sess] -> unit io
        val read_res : conn -> [`Res of int data * 'p0] io
        val read_bye : conn -> [`Bye of unit data * 'p0] io
      end) = struct
      type conn = X.conn
      let role : ([>`S of X.conn * 'lab], X.conn, 'lab) role =
        {_pack_role=(fun labels -> `S(labels)) ; _repr="role_S"; _kind=X.conn}

      let add : 'p. ([>`Add of (int * int) data * 'p sess], X.conn, (int * int) data * 'p sess) label =
        {_pack_label=(fun payload -> `Add(payload)); _send=X.write_add}
      let bye : 'p. ([>`Bye of unit data * 'p sess], X.conn, unit data * 'p sess) label =
        {_pack_label=(fun payload -> `Bye(payload)); _send=X.write_bye}
      let receive_res  : type p0. ([`Res of int data * p0], X.conn) labels =
        {_receive=X.read_res}
      let receive_bye  : type p0. ([`Bye of unit data * p0], X.conn) labels =
        {_receive=X.read_bye}
    end

    module Raw = struct
      include Make(struct
          type conn = Shmem.Raw.t
          let conn = Shmem.MPSTChannel.Raw
          let write_add = Shmem.Raw.send
          let write_bye = Shmem.Raw.send
          let read_res = Shmem.Raw.receive
          let read_bye = Shmem.Raw.receive
        end)
    end
  end

end

module S = struct
  let initiate_shmem : 'c. adder -> ('c, 'c, Shmem.Raw.t adder_S sess) monad = fun (ShmemMPSTChanenl__(c)) ->
    Internal.__start (Shmem.MPSTChannel.connect c ~role:"role_S")

  module C = struct
    module Make(X:sig
        type conn
        val conn : conn Endpoint.conn_kind
        val write_res : conn -> [>`Res of int data * 'p sess] -> unit io
        val write_bye : conn -> [>`Bye of unit data * 'p sess] -> unit io
        val read_add_or_bye : conn -> [`Add of (int * int) data * 'p0|`Bye of unit data * 'p1] io
      end) = struct
      type conn = X.conn
      let role : ([>`C of X.conn * 'lab], X.conn, 'lab) role =
        {_pack_role=(fun labels -> `C(labels)) ; _repr="role_C"; _kind=X.conn}

      let res : 'p. ([>`Res of int data * 'p sess], X.conn, int data * 'p sess) label =
        {_pack_label=(fun payload -> `Res(payload)); _send=X.write_res}
      let bye : 'p. ([>`Bye of unit data * 'p sess], X.conn, unit data * 'p sess) label =
        {_pack_label=(fun payload -> `Bye(payload)); _send=X.write_bye}
      let receive_add_or_bye  : type p0 p1. ([`Add of (int * int) data * p0|`Bye of unit data * p1], X.conn) labels =
        {_receive=X.read_add_or_bye}
    end

    module Raw = struct
      include Make(struct
          type conn = Shmem.Raw.t
          let conn = Shmem.MPSTChannel.Raw
          let write_res = Shmem.Raw.send
          let write_bye = Shmem.Raw.send
          let read_add_or_bye = Shmem.Raw.receive
        end)
    end
  end

end

end