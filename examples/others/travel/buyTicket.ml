(* Generated from scribble-ocaml https://github.com/keigoi/scribble-ocaml
 * This code should be compiled with scribble-ocaml-runtime
 * https://github.com/keigoi/scribble-ocaml-runtime *)


module Make (Session:Scribble.S.SESSION)  = struct
  type travel = string
  type price = int
  type code = string

open Session

type ('c_A, 'c_F) buyTicket_R = ('c_A, 'c_F) buyTicket_R_1
and ('c_A, 'c_F) buyTicket_R_1 =
  [`send of [`A of 'c_A * [`request of travel data *
    [`recv of [`A of 'c_A * [`quote of price data *
      [`send of [`F of 'c_F * [`check of price data *
        [`recv of [`F of 'c_F *
          [`approve of code data *
            [`recv of [`A of 'c_A * [`ticket of string data *
              [`close] sess]]] sess
          |`refuse of string data *
            [`close] sess]]] sess]]] sess]]] sess]]]
type ('c_R, 'c_F) buyTicket_A = ('c_R, 'c_F) buyTicket_A_1
and ('c_R, 'c_F) buyTicket_A_1 =
  [`recv of [`R of 'c_R * [`request of travel data *
    [`send of [`R of 'c_R * [`quote of price data *
      [`recv of [`F of 'c_F *
        [`approve of code data *
          [`send of [`R of 'c_R * [`ticket of string data *
            [`send of [`F of 'c_F * [`invoice of code data *
              [`recv of [`F of 'c_F * [`payment of price data *
                [`close] sess]]] sess]]] sess]]] sess
        |`refuse of string data *
          [`close] sess]]] sess]]] sess]]]
type ('c_R, 'c_A) buyTicket_F = ('c_R, 'c_A) buyTicket_F_1
and ('c_R, 'c_A) buyTicket_F_1 =
  [`recv of [`R of 'c_R * [`check of price data *
    [`send of [`R of 'c_R *
      [`approve of code data *
        [`send of [`A of 'c_A * [`approve of code data *
          [`recv of [`A of 'c_A * [`invoice of code data *
            [`send of [`A of 'c_A * [`payment of price data *
              [`close] sess]]] sess]]] sess]]] sess
      |`refuse of string data *
        [`send of [`A of 'c_A * [`refuse of string data *
          [`close] sess]]] sess]]] sess]]]


module Shmem = Scribble.Shmem.Make(Session.LinIO.IO)(Session.Mutex)(Session.Condition)(Session.Endpoint)

type buyTicket = ShmemMPSTChanenl__ of Shmem.MPSTChannel.t
let create_shmem_channel : unit -> buyTicket = fun () ->
  ShmemMPSTChanenl__(Shmem.MPSTChannel.create ~acceptor_role:"role_R" ~connector_roles:["role_A"; "role_F"])


module R = struct
  let initiate_shmem : 'c. buyTicket -> ('c, 'c, (Shmem.Raw.t, Shmem.Raw.t) buyTicket_R sess) monad = fun (ShmemMPSTChanenl__(c)) ->
    Internal.__start (Shmem.MPSTChannel.accept c ~role:"role_R")

  module A = struct
    module Make(X:sig
        type conn
        val conn : conn Endpoint.conn_kind
        val write_request : conn -> [>`request of travel data * 'p sess] -> unit io
        val read_quote : conn -> [`quote of price data * 'p0] io
        val read_ticket : conn -> [`ticket of string data * 'p0] io
      end) = struct
      type conn = X.conn
      let role : ([>`A of X.conn * 'lab], X.conn, 'lab) role =
        {_pack_role=(fun labels -> `A(labels)) ; _repr="role_A"; _kind=X.conn}

      let request : 'p. ([>`request of travel data * 'p sess], X.conn, travel data * 'p sess) label =
        {_pack_label=(fun payload -> `request(payload)); _send=X.write_request}
      let receive_quote  : type p0. ([`quote of price data * p0], X.conn) labels =
        {_receive=X.read_quote}
      let receive_ticket  : type p0. ([`ticket of string data * p0], X.conn) labels =
        {_receive=X.read_ticket}
    end

    module Raw = struct
      include Make(struct
          type conn = Shmem.Raw.t
          let conn = Shmem.MPSTChannel.Raw
          let write_request = Shmem.Raw.send
          let read_quote = Shmem.Raw.receive
          let read_ticket = Shmem.Raw.receive
        end)
    end
  end
  module F = struct
    module Make(X:sig
        type conn
        val conn : conn Endpoint.conn_kind
        val write_check : conn -> [>`check of price data * 'p sess] -> unit io
        val read_approve_or_refuse : conn -> [`approve of code data * 'p0|`refuse of string data * 'p1] io
      end) = struct
      type conn = X.conn
      let role : ([>`F of X.conn * 'lab], X.conn, 'lab) role =
        {_pack_role=(fun labels -> `F(labels)) ; _repr="role_F"; _kind=X.conn}

      let check : 'p. ([>`check of price data * 'p sess], X.conn, price data * 'p sess) label =
        {_pack_label=(fun payload -> `check(payload)); _send=X.write_check}
      let receive_approve_or_refuse  : type p0 p1. ([`approve of code data * p0|`refuse of string data * p1], X.conn) labels =
        {_receive=X.read_approve_or_refuse}
    end

    module Raw = struct
      include Make(struct
          type conn = Shmem.Raw.t
          let conn = Shmem.MPSTChannel.Raw
          let write_check = Shmem.Raw.send
          let read_approve_or_refuse = Shmem.Raw.receive
        end)
    end
  end

end

module A = struct
  let initiate_shmem : 'c. buyTicket -> ('c, 'c, (Shmem.Raw.t, Shmem.Raw.t) buyTicket_A sess) monad = fun (ShmemMPSTChanenl__(c)) ->
    Internal.__start (Shmem.MPSTChannel.connect c ~role:"role_A")

  module R = struct
    module Make(X:sig
        type conn
        val conn : conn Endpoint.conn_kind
        val write_quote : conn -> [>`quote of price data * 'p sess] -> unit io
        val write_ticket : conn -> [>`ticket of string data * 'p sess] -> unit io
        val read_request : conn -> [`request of travel data * 'p0] io
      end) = struct
      type conn = X.conn
      let role : ([>`R of X.conn * 'lab], X.conn, 'lab) role =
        {_pack_role=(fun labels -> `R(labels)) ; _repr="role_R"; _kind=X.conn}

      let quote : 'p. ([>`quote of price data * 'p sess], X.conn, price data * 'p sess) label =
        {_pack_label=(fun payload -> `quote(payload)); _send=X.write_quote}
      let ticket : 'p. ([>`ticket of string data * 'p sess], X.conn, string data * 'p sess) label =
        {_pack_label=(fun payload -> `ticket(payload)); _send=X.write_ticket}
      let receive_request  : type p0. ([`request of travel data * p0], X.conn) labels =
        {_receive=X.read_request}
    end

    module Raw = struct
      include Make(struct
          type conn = Shmem.Raw.t
          let conn = Shmem.MPSTChannel.Raw
          let write_quote = Shmem.Raw.send
          let write_ticket = Shmem.Raw.send
          let read_request = Shmem.Raw.receive
        end)
    end
  end
  module F = struct
    module Make(X:sig
        type conn
        val conn : conn Endpoint.conn_kind
        val write_invoice : conn -> [>`invoice of code data * 'p sess] -> unit io
        val read_approve_or_refuse : conn -> [`approve of code data * 'p0|`refuse of string data * 'p1] io
        val read_payment : conn -> [`payment of price data * 'p0] io
      end) = struct
      type conn = X.conn
      let role : ([>`F of X.conn * 'lab], X.conn, 'lab) role =
        {_pack_role=(fun labels -> `F(labels)) ; _repr="role_F"; _kind=X.conn}

      let invoice : 'p. ([>`invoice of code data * 'p sess], X.conn, code data * 'p sess) label =
        {_pack_label=(fun payload -> `invoice(payload)); _send=X.write_invoice}
      let receive_approve_or_refuse  : type p0 p1. ([`approve of code data * p0|`refuse of string data * p1], X.conn) labels =
        {_receive=X.read_approve_or_refuse}
      let receive_payment  : type p0. ([`payment of price data * p0], X.conn) labels =
        {_receive=X.read_payment}
    end

    module Raw = struct
      include Make(struct
          type conn = Shmem.Raw.t
          let conn = Shmem.MPSTChannel.Raw
          let write_invoice = Shmem.Raw.send
          let read_approve_or_refuse = Shmem.Raw.receive
          let read_payment = Shmem.Raw.receive
        end)
    end
  end

end

module F = struct
  let initiate_shmem : 'c. buyTicket -> ('c, 'c, (Shmem.Raw.t, Shmem.Raw.t) buyTicket_F sess) monad = fun (ShmemMPSTChanenl__(c)) ->
    Internal.__start (Shmem.MPSTChannel.connect c ~role:"role_F")

  module R = struct
    module Make(X:sig
        type conn
        val conn : conn Endpoint.conn_kind
        val write_approve : conn -> [>`approve of code data * 'p sess] -> unit io
        val write_refuse : conn -> [>`refuse of string data * 'p sess] -> unit io
        val read_check : conn -> [`check of price data * 'p0] io
      end) = struct
      type conn = X.conn
      let role : ([>`R of X.conn * 'lab], X.conn, 'lab) role =
        {_pack_role=(fun labels -> `R(labels)) ; _repr="role_R"; _kind=X.conn}

      let approve : 'p. ([>`approve of code data * 'p sess], X.conn, code data * 'p sess) label =
        {_pack_label=(fun payload -> `approve(payload)); _send=X.write_approve}
      let refuse : 'p. ([>`refuse of string data * 'p sess], X.conn, string data * 'p sess) label =
        {_pack_label=(fun payload -> `refuse(payload)); _send=X.write_refuse}
      let receive_check  : type p0. ([`check of price data * p0], X.conn) labels =
        {_receive=X.read_check}
    end

    module Raw = struct
      include Make(struct
          type conn = Shmem.Raw.t
          let conn = Shmem.MPSTChannel.Raw
          let write_approve = Shmem.Raw.send
          let write_refuse = Shmem.Raw.send
          let read_check = Shmem.Raw.receive
        end)
    end
  end
  module A = struct
    module Make(X:sig
        type conn
        val conn : conn Endpoint.conn_kind
        val write_approve : conn -> [>`approve of code data * 'p sess] -> unit io
        val write_payment : conn -> [>`payment of price data * 'p sess] -> unit io
        val write_refuse : conn -> [>`refuse of string data * 'p sess] -> unit io
        val read_invoice : conn -> [`invoice of code data * 'p0] io
      end) = struct
      type conn = X.conn
      let role : ([>`A of X.conn * 'lab], X.conn, 'lab) role =
        {_pack_role=(fun labels -> `A(labels)) ; _repr="role_A"; _kind=X.conn}

      let approve : 'p. ([>`approve of code data * 'p sess], X.conn, code data * 'p sess) label =
        {_pack_label=(fun payload -> `approve(payload)); _send=X.write_approve}
      let payment : 'p. ([>`payment of price data * 'p sess], X.conn, price data * 'p sess) label =
        {_pack_label=(fun payload -> `payment(payload)); _send=X.write_payment}
      let refuse : 'p. ([>`refuse of string data * 'p sess], X.conn, string data * 'p sess) label =
        {_pack_label=(fun payload -> `refuse(payload)); _send=X.write_refuse}
      let receive_invoice  : type p0. ([`invoice of code data * p0], X.conn) labels =
        {_receive=X.read_invoice}
    end

    module Raw = struct
      include Make(struct
          type conn = Shmem.Raw.t
          let conn = Shmem.MPSTChannel.Raw
          let write_approve = Shmem.Raw.send
          let write_payment = Shmem.Raw.send
          let write_refuse = Shmem.Raw.send
          let read_invoice = Shmem.Raw.receive
        end)
    end
  end

end

end