(* Generated from scribble-ocaml https://github.com/keigoi/scribble-ocaml
 * This code should be compiled with scribble-ocaml-runtime
 * https://github.com/keigoi/scribble-ocaml-runtime *)


module Make (Session:Scribble.S.SESSION)  = struct
  type int = java.lang.Integer

open Session

type ('c_S) mathService_C = ('c_S) mathService_C_1
and ('c_S) mathService_C_1 =
  [`send of [`S of 'c_S *
    [`Val of int data *
      [`send of [`S of 'c_S *
        [`Add of int data *
          [`recv of [`S of 'c_S * [`Sum of int data *
            ('c_S) mathService_C_1 sess]]] sess
        |`Mult of int data *
          [`recv of [`S of 'c_S * [`Prod of int data *
            ('c_S) mathService_C_1 sess]]] sess]]] sess
    |`Bye of unit data *
      [`close] sess]]]
type ('c_C) mathService_S = ('c_C) mathService_S_1
and ('c_C) mathService_S_1 =
  [`recv of [`C of 'c_C *
    [`Val of int data *
      [`recv of [`C of 'c_C *
        [`Add of int data *
          [`send of [`C of 'c_C * [`Sum of int data *
            ('c_C) mathService_S_1 sess]]] sess
        |`Mult of int data *
          [`send of [`C of 'c_C * [`Prod of int data *
            ('c_C) mathService_S_1 sess]]] sess]]] sess
    |`Bye of unit data *
      [`close] sess]]]


module Shmem = Scribble.Shmem.Make(Session.LinIO.IO)(Session.Mutex)(Session.Condition)(Session.Endpoint)

type mathService = ShmemMPSTChanenl__ of Shmem.MPSTChannel.t
let create_shmem_channel : unit -> mathService = fun () ->
  ShmemMPSTChanenl__(Shmem.MPSTChannel.create ~acceptor_role:"role_C" ~connector_roles:["role_S";])


module C = struct
  let initiate_shmem : 'c. mathService -> ('c, 'c, Shmem.Raw.t mathService_C sess) monad = fun (ShmemMPSTChanenl__(c)) ->
    Internal.__start (Shmem.MPSTChannel.accept c ~role:"role_C")

  module S = struct
    module Make(X:sig
        type conn
        val conn : conn Endpoint.conn_kind
        val write_val : conn -> [>`Val of int data * 'p sess] -> unit io
        val write_bye : conn -> [>`Bye of unit data * 'p sess] -> unit io
        val write_add : conn -> [>`Add of int data * 'p sess] -> unit io
        val write_mult : conn -> [>`Mult of int data * 'p sess] -> unit io
        val read_sum : conn -> [`Sum of int data * 'p0] io
        val read_prod : conn -> [`Prod of int data * 'p0] io
      end) = struct
      type conn = X.conn
      let role : ([>`S of X.conn * 'lab], X.conn, 'lab) role =
        {_pack_role=(fun labels -> `S(labels)) ; _repr="role_S"; _kind=X.conn}

      let val : 'p. ([>`Val of int data * 'p sess], X.conn, int data * 'p sess) label =
        {_pack_label=(fun payload -> `Val(payload)); _send=X.write_val}
      let bye : 'p. ([>`Bye of unit data * 'p sess], X.conn, unit data * 'p sess) label =
        {_pack_label=(fun payload -> `Bye(payload)); _send=X.write_bye}
      let add : 'p. ([>`Add of int data * 'p sess], X.conn, int data * 'p sess) label =
        {_pack_label=(fun payload -> `Add(payload)); _send=X.write_add}
      let mult : 'p. ([>`Mult of int data * 'p sess], X.conn, int data * 'p sess) label =
        {_pack_label=(fun payload -> `Mult(payload)); _send=X.write_mult}
      let receive_sum  : type p0. ([`Sum of int data * p0], X.conn) labels =
        {_receive=X.read_sum}
      let receive_prod  : type p0. ([`Prod of int data * p0], X.conn) labels =
        {_receive=X.read_prod}
    end

    module Raw = struct
      include Make(struct
          type conn = Shmem.Raw.t
          let conn = Shmem.MPSTChannel.Raw
          let write_val = Shmem.Raw.send
          let write_bye = Shmem.Raw.send
          let write_add = Shmem.Raw.send
          let write_mult = Shmem.Raw.send
          let read_sum = Shmem.Raw.receive
          let read_prod = Shmem.Raw.receive
        end)
    end
  end

end

module S = struct
  let initiate_shmem : 'c. mathService -> ('c, 'c, Shmem.Raw.t mathService_S sess) monad = fun (ShmemMPSTChanenl__(c)) ->
    Internal.__start (Shmem.MPSTChannel.connect c ~role:"role_S")

  module C = struct
    module Make(X:sig
        type conn
        val conn : conn Endpoint.conn_kind
        val write_sum : conn -> [>`Sum of int data * 'p sess] -> unit io
        val write_prod : conn -> [>`Prod of int data * 'p sess] -> unit io
        val read_val_or_bye : conn -> [`Val of int data * 'p0|`Bye of unit data * 'p1] io
        val read_add_or_mult : conn -> [`Add of int data * 'p0|`Mult of int data * 'p1] io
      end) = struct
      type conn = X.conn
      let role : ([>`C of X.conn * 'lab], X.conn, 'lab) role =
        {_pack_role=(fun labels -> `C(labels)) ; _repr="role_C"; _kind=X.conn}

      let sum : 'p. ([>`Sum of int data * 'p sess], X.conn, int data * 'p sess) label =
        {_pack_label=(fun payload -> `Sum(payload)); _send=X.write_sum}
      let prod : 'p. ([>`Prod of int data * 'p sess], X.conn, int data * 'p sess) label =
        {_pack_label=(fun payload -> `Prod(payload)); _send=X.write_prod}
      let receive_val_or_bye  : type p0 p1. ([`Val of int data * p0|`Bye of unit data * p1], X.conn) labels =
        {_receive=X.read_val_or_bye}
      let receive_add_or_mult  : type p0 p1. ([`Add of int data * p0|`Mult of int data * p1], X.conn) labels =
        {_receive=X.read_add_or_mult}
    end

    module Raw = struct
      include Make(struct
          type conn = Shmem.Raw.t
          let conn = Shmem.MPSTChannel.Raw
          let write_sum = Shmem.Raw.send
          let write_prod = Shmem.Raw.send
          let read_val_or_bye = Shmem.Raw.receive
          let read_add_or_mult = Shmem.Raw.receive
        end)
    end
  end

end

end