(* Generated from scribble-ocaml https://github.com/keigoi/scribble-ocaml
 * This code should be compiled with scribble-ocaml-runtime
 * https://github.com/keigoi/scribble-ocaml-runtime *)


module Make (Session:Scribble.S.SESSION)  = struct


open Session

type ('c_S) smtp_C = ('c_S) smtp_C_1
and ('c_S) smtp_C_1 =
  [`recv of [`S of 'c_S * [`_220 of unit data *
    [`send of [`S of 'c_S * [`Ehlo of unit data *
      ('c_S) smtp_C_2 sess]]] sess]]]
and ('c_S) smtp_C_2 =
  [`recv of [`S of 'c_S *
    [`_250d of unit data *
      ('c_S) smtp_C_2 sess
    |`_250 of unit data *
      [`send of [`S of 'c_S * [`StartTls of unit data *
        [`recv of [`S of 'c_S * [`_220 of unit data *
          [`send of [`S of 'c_S * [`Ehlo of unit data *
            ('c_S) smtp_C_3 sess]]] sess]]] sess]]] sess]]]
and ('c_S) smtp_C_3 =
  [`recv of [`S of 'c_S *
    [`_250d of unit data *
      ('c_S) smtp_C_3 sess
    |`_250 of unit data *
      [`send of [`S of 'c_S * [`Quit of unit data *
        [`close] sess]]] sess]]]
type ('c_C) smtp_S = ('c_C) smtp_S_1
and ('c_C) smtp_S_1 =
  [`send of [`C of 'c_C * [`_220 of unit data *
    [`recv of [`C of 'c_C * [`Ehlo of unit data *
      ('c_C) smtp_S_2 sess]]] sess]]]
and ('c_C) smtp_S_2 =
  [`send of [`C of 'c_C *
    [`_250d of unit data *
      ('c_C) smtp_S_2 sess
    |`_250 of unit data *
      [`recv of [`C of 'c_C * [`StartTls of unit data *
        [`send of [`C of 'c_C * [`_220 of unit data *
          [`recv of [`C of 'c_C * [`Ehlo of unit data *
            ('c_C) smtp_S_3 sess]]] sess]]] sess]]] sess]]]
and ('c_C) smtp_S_3 =
  [`send of [`C of 'c_C *
    [`_250d of unit data *
      ('c_C) smtp_S_3 sess
    |`_250 of unit data *
      [`recv of [`C of 'c_C * [`Quit of unit data *
        [`close] sess]]] sess]]]


module Shmem = Scribble.Shmem.Make(Session.LinIO.IO)(Session.Mutex)(Session.Condition)(Session.Endpoint)

type smtp = ShmemMPSTChanenl__ of Shmem.MPSTChannel.t
let create_shmem_channel : unit -> smtp = fun () ->
  ShmemMPSTChanenl__(Shmem.MPSTChannel.create ~acceptor_role:"role_C" ~connector_roles:["role_S";])


module C = struct
  let initiate_shmem : 'c. smtp -> ('c, 'c, Shmem.Raw.t smtp_C sess) monad = fun (ShmemMPSTChanenl__(c)) ->
    Internal.__start (Shmem.MPSTChannel.accept c ~role:"role_C")

  module S = struct
    module Make(X:sig
        type conn
        val conn : conn Endpoint.conn_kind
        val write_ehlo : conn -> [>`Ehlo of unit data * 'p sess] -> unit io
        val write_startTls : conn -> [>`StartTls of unit data * 'p sess] -> unit io
        val write_quit : conn -> [>`Quit of unit data * 'p sess] -> unit io
        val read__220 : conn -> [`_220 of unit data * 'p0] io
        val read__250d_or__250 : conn -> [`_250d of unit data * 'p0|`_250 of unit data * 'p1] io
      end) = struct
      type conn = X.conn
      let role : ([>`S of X.conn * 'lab], X.conn, 'lab) role =
        {_pack_role=(fun labels -> `S(labels)) ; _repr="role_S"; _kind=X.conn}

      let ehlo : 'p. ([>`Ehlo of unit data * 'p sess], X.conn, unit data * 'p sess) label =
        {_pack_label=(fun payload -> `Ehlo(payload)); _send=X.write_ehlo}
      let startTls : 'p. ([>`StartTls of unit data * 'p sess], X.conn, unit data * 'p sess) label =
        {_pack_label=(fun payload -> `StartTls(payload)); _send=X.write_startTls}
      let quit : 'p. ([>`Quit of unit data * 'p sess], X.conn, unit data * 'p sess) label =
        {_pack_label=(fun payload -> `Quit(payload)); _send=X.write_quit}
      let receive__220  : type p0. ([`_220 of unit data * p0], X.conn) labels =
        {_receive=X.read__220}
      let receive__250d_or__250  : type p0 p1. ([`_250d of unit data * p0|`_250 of unit data * p1], X.conn) labels =
        {_receive=X.read__250d_or__250}
    end

    module Raw = struct
      include Make(struct
          type conn = Shmem.Raw.t
          let conn = Shmem.MPSTChannel.Raw
          let write_ehlo = Shmem.Raw.send
          let write_startTls = Shmem.Raw.send
          let write_quit = Shmem.Raw.send
          let read__220 = Shmem.Raw.receive
          let read__250d_or__250 = Shmem.Raw.receive
        end)
    end
  end

end

module S = struct
  let initiate_shmem : 'c. smtp -> ('c, 'c, Shmem.Raw.t smtp_S sess) monad = fun (ShmemMPSTChanenl__(c)) ->
    Internal.__start (Shmem.MPSTChannel.connect c ~role:"role_S")

  module C = struct
    module Make(X:sig
        type conn
        val conn : conn Endpoint.conn_kind
        val write__220 : conn -> [>`_220 of unit data * 'p sess] -> unit io
        val write__250d : conn -> [>`_250d of unit data * 'p sess] -> unit io
        val write__250 : conn -> [>`_250 of unit data * 'p sess] -> unit io
        val read_ehlo : conn -> [`Ehlo of unit data * 'p0] io
        val read_startTls : conn -> [`StartTls of unit data * 'p0] io
        val read_quit : conn -> [`Quit of unit data * 'p0] io
      end) = struct
      type conn = X.conn
      let role : ([>`C of X.conn * 'lab], X.conn, 'lab) role =
        {_pack_role=(fun labels -> `C(labels)) ; _repr="role_C"; _kind=X.conn}

      let _220 : 'p. ([>`_220 of unit data * 'p sess], X.conn, unit data * 'p sess) label =
        {_pack_label=(fun payload -> `_220(payload)); _send=X.write__220}
      let _250d : 'p. ([>`_250d of unit data * 'p sess], X.conn, unit data * 'p sess) label =
        {_pack_label=(fun payload -> `_250d(payload)); _send=X.write__250d}
      let _250 : 'p. ([>`_250 of unit data * 'p sess], X.conn, unit data * 'p sess) label =
        {_pack_label=(fun payload -> `_250(payload)); _send=X.write__250}
      let receive_ehlo  : type p0. ([`Ehlo of unit data * p0], X.conn) labels =
        {_receive=X.read_ehlo}
      let receive_startTls  : type p0. ([`StartTls of unit data * p0], X.conn) labels =
        {_receive=X.read_startTls}
      let receive_quit  : type p0. ([`Quit of unit data * p0], X.conn) labels =
        {_receive=X.read_quit}
    end

    module Raw = struct
      include Make(struct
          type conn = Shmem.Raw.t
          let conn = Shmem.MPSTChannel.Raw
          let write__220 = Shmem.Raw.send
          let write__250d = Shmem.Raw.send
          let write__250 = Shmem.Raw.send
          let read_ehlo = Shmem.Raw.receive
          let read_startTls = Shmem.Raw.receive
          let read_quit = Shmem.Raw.receive
        end)
    end
  end

end

end