(* Generated from scribble-ocaml https://github.com/keigoi/scribble-ocaml
 * This code should be compiled with scribble-ocaml-runtime
 * https://github.com/keigoi/scribble-ocaml-runtime *)


module Make (Session:Scribble.S.SESSION)  = struct
  type date = string

open Session

type ('c_A, 'c_S) travelAgency_C = ('c_A, 'c_S) travelAgency_C_1
and ('c_A, 'c_S) travelAgency_C_1 =
  [`send of [`A of 'c_A *
    [`Query of string data *
      [`recv of [`A of 'c_A * [`Price of int data *
        ('c_A, 'c_S) travelAgency_C_1 sess]]] sess
    |`Accept of unit data *
      [`send of [`S of 'c_S * [`Address of string data *
        [`recv of [`S of 'c_S * [`msg of date data *
          [`close] sess]]] sess]]] sess
    |`Reject of unit data *
      [`close] sess]]]
type ('c_C, 'c_S) travelAgency_A = ('c_C, 'c_S) travelAgency_A_1
and ('c_C, 'c_S) travelAgency_A_1 =
  [`recv of [`C of 'c_C *
    [`Query of string data *
      [`send of [`C of 'c_C * [`Price of int data *
        [`send of [`S of 'c_S * [`Info of string data *
          ('c_C, 'c_S) travelAgency_A_1 sess]]] sess]]] sess
    |`Accept of unit data *
      [`send of [`S of 'c_S * [`Accept of unit data *
        [`close] sess]]] sess
    |`Reject of unit data *
      [`send of [`S of 'c_S * [`Reject of unit data *
        [`close] sess]]] sess]]]
type ('c_C, 'c_A) travelAgency_S = ('c_C, 'c_A) travelAgency_S_1
and ('c_C, 'c_A) travelAgency_S_1 =
  [`recv of [`A of 'c_A *
    [`Info of string data *
      ('c_C, 'c_A) travelAgency_S_1 sess
    |`Accept of unit data *
      [`recv of [`C of 'c_C * [`Address of string data *
        [`send of [`C of 'c_C * [`msg of date data *
          [`close] sess]]] sess]]] sess
    |`Reject of unit data *
      [`close] sess]]]


module Shmem = Scribble.Shmem.Make(Session.LinIO.IO)(Session.Mutex)(Session.Condition)(Session.Endpoint)

type travelAgency = ShmemMPSTChanenl__ of Shmem.MPSTChannel.t
let create_shmem_channel : unit -> travelAgency = fun () ->
  ShmemMPSTChanenl__(Shmem.MPSTChannel.create ~acceptor_role:"role_C" ~connector_roles:["role_A"; "role_S"])


module C = struct
  let initiate_shmem : 'c. travelAgency -> ('c, 'c, (Shmem.Raw.t, Shmem.Raw.t) travelAgency_C sess) monad = fun (ShmemMPSTChanenl__(c)) ->
    Internal.__start (Shmem.MPSTChannel.accept c ~role:"role_C")

  module A = struct
    module Make(X:sig
        type conn
        val conn : conn Endpoint.conn_kind
        val write_query : conn -> [>`Query of string data * 'p sess] -> unit io
        val write_accept : conn -> [>`Accept of unit data * 'p sess] -> unit io
        val write_reject : conn -> [>`Reject of unit data * 'p sess] -> unit io
        val read_price : conn -> [`Price of int data * 'p0] io
      end) = struct
      type conn = X.conn
      let role : ([>`A of X.conn * 'lab], X.conn, 'lab) role =
        {_pack_role=(fun labels -> `A(labels)) ; _repr="role_A"; _kind=X.conn}

      let query : 'p. ([>`Query of string data * 'p sess], X.conn, string data * 'p sess) label =
        {_pack_label=(fun payload -> `Query(payload)); _send=X.write_query}
      let accept : 'p. ([>`Accept of unit data * 'p sess], X.conn, unit data * 'p sess) label =
        {_pack_label=(fun payload -> `Accept(payload)); _send=X.write_accept}
      let reject : 'p. ([>`Reject of unit data * 'p sess], X.conn, unit data * 'p sess) label =
        {_pack_label=(fun payload -> `Reject(payload)); _send=X.write_reject}
      let receive_price  : type p0. ([`Price of int data * p0], X.conn) labels =
        {_receive=X.read_price}
    end

    module Raw = struct
      include Make(struct
          type conn = Shmem.Raw.t
          let conn = Shmem.MPSTChannel.Raw
          let write_query = Shmem.Raw.send
          let write_accept = Shmem.Raw.send
          let write_reject = Shmem.Raw.send
          let read_price = Shmem.Raw.receive
        end)
    end
  end
  module S = struct
    module Make(X:sig
        type conn
        val conn : conn Endpoint.conn_kind
        val write_address : conn -> [>`Address of string data * 'p sess] -> unit io
        val read_msg : conn -> [`msg of date data * 'p0] io
      end) = struct
      type conn = X.conn
      let role : ([>`S of X.conn * 'lab], X.conn, 'lab) role =
        {_pack_role=(fun labels -> `S(labels)) ; _repr="role_S"; _kind=X.conn}

      let address : 'p. ([>`Address of string data * 'p sess], X.conn, string data * 'p sess) label =
        {_pack_label=(fun payload -> `Address(payload)); _send=X.write_address}
      let receive_msg  : type p0. ([`msg of date data * p0], X.conn) labels =
        {_receive=X.read_msg}
    end

    module Raw = struct
      include Make(struct
          type conn = Shmem.Raw.t
          let conn = Shmem.MPSTChannel.Raw
          let write_address = Shmem.Raw.send
          let read_msg = Shmem.Raw.receive
        end)
    end
  end

end

module A = struct
  let initiate_shmem : 'c. travelAgency -> ('c, 'c, (Shmem.Raw.t, Shmem.Raw.t) travelAgency_A sess) monad = fun (ShmemMPSTChanenl__(c)) ->
    Internal.__start (Shmem.MPSTChannel.connect c ~role:"role_A")

  module C = struct
    module Make(X:sig
        type conn
        val conn : conn Endpoint.conn_kind
        val write_price : conn -> [>`Price of int data * 'p sess] -> unit io
        val read_query_or_accept_or_reject : conn -> [`Query of string data * 'p0|`Accept of unit data * 'p1|`Reject of unit data * 'p2] io
      end) = struct
      type conn = X.conn
      let role : ([>`C of X.conn * 'lab], X.conn, 'lab) role =
        {_pack_role=(fun labels -> `C(labels)) ; _repr="role_C"; _kind=X.conn}

      let price : 'p. ([>`Price of int data * 'p sess], X.conn, int data * 'p sess) label =
        {_pack_label=(fun payload -> `Price(payload)); _send=X.write_price}
      let receive_query_or_accept_or_reject  : type p0 p1 p2. ([`Query of string data * p0|`Accept of unit data * p1|`Reject of unit data * p2], X.conn) labels =
        {_receive=X.read_query_or_accept_or_reject}
    end

    module Raw = struct
      include Make(struct
          type conn = Shmem.Raw.t
          let conn = Shmem.MPSTChannel.Raw
          let write_price = Shmem.Raw.send
          let read_query_or_accept_or_reject = Shmem.Raw.receive
        end)
    end
  end
  module S = struct
    module Make(X:sig
        type conn
        val conn : conn Endpoint.conn_kind
        val write_info : conn -> [>`Info of string data * 'p sess] -> unit io
        val write_accept : conn -> [>`Accept of unit data * 'p sess] -> unit io
        val write_reject : conn -> [>`Reject of unit data * 'p sess] -> unit io
      end) = struct
      type conn = X.conn
      let role : ([>`S of X.conn * 'lab], X.conn, 'lab) role =
        {_pack_role=(fun labels -> `S(labels)) ; _repr="role_S"; _kind=X.conn}

      let info : 'p. ([>`Info of string data * 'p sess], X.conn, string data * 'p sess) label =
        {_pack_label=(fun payload -> `Info(payload)); _send=X.write_info}
      let accept : 'p. ([>`Accept of unit data * 'p sess], X.conn, unit data * 'p sess) label =
        {_pack_label=(fun payload -> `Accept(payload)); _send=X.write_accept}
      let reject : 'p. ([>`Reject of unit data * 'p sess], X.conn, unit data * 'p sess) label =
        {_pack_label=(fun payload -> `Reject(payload)); _send=X.write_reject}
    end

    module Raw = struct
      include Make(struct
          type conn = Shmem.Raw.t
          let conn = Shmem.MPSTChannel.Raw
          let write_info = Shmem.Raw.send
          let write_accept = Shmem.Raw.send
          let write_reject = Shmem.Raw.send
        end)
    end
  end

end

module S = struct
  let initiate_shmem : 'c. travelAgency -> ('c, 'c, (Shmem.Raw.t, Shmem.Raw.t) travelAgency_S sess) monad = fun (ShmemMPSTChanenl__(c)) ->
    Internal.__start (Shmem.MPSTChannel.connect c ~role:"role_S")

  module C = struct
    module Make(X:sig
        type conn
        val conn : conn Endpoint.conn_kind
        val write_msg : conn -> [>`msg of date data * 'p sess] -> unit io
        val read_address : conn -> [`Address of string data * 'p0] io
      end) = struct
      type conn = X.conn
      let role : ([>`C of X.conn * 'lab], X.conn, 'lab) role =
        {_pack_role=(fun labels -> `C(labels)) ; _repr="role_C"; _kind=X.conn}

      let msg : 'p. ([>`msg of date data * 'p sess], X.conn, date data * 'p sess) label =
        {_pack_label=(fun payload -> `msg(payload)); _send=X.write_msg}
      let receive_address  : type p0. ([`Address of string data * p0], X.conn) labels =
        {_receive=X.read_address}
    end

    module Raw = struct
      include Make(struct
          type conn = Shmem.Raw.t
          let conn = Shmem.MPSTChannel.Raw
          let write_msg = Shmem.Raw.send
          let read_address = Shmem.Raw.receive
        end)
    end
  end
  module A = struct
    module Make(X:sig
        type conn
        val conn : conn Endpoint.conn_kind
        val read_info_or_accept_or_reject : conn -> [`Info of string data * 'p0|`Accept of unit data * 'p1|`Reject of unit data * 'p2] io
      end) = struct
      type conn = X.conn
      let role : ([>`A of X.conn * 'lab], X.conn, 'lab) role =
        {_pack_role=(fun labels -> `A(labels)) ; _repr="role_A"; _kind=X.conn}

      let receive_info_or_accept_or_reject  : type p0 p1 p2. ([`Info of string data * p0|`Accept of unit data * p1|`Reject of unit data * p2], X.conn) labels =
        {_receive=X.read_info_or_accept_or_reject}
    end

    module Raw = struct
      include Make(struct
          type conn = Shmem.Raw.t
          let conn = Shmem.MPSTChannel.Raw
          let read_info_or_accept_or_reject = Shmem.Raw.receive
        end)
    end
  end

end

end