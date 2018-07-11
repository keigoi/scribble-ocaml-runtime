(* Generated from scribble-ocaml https://github.com/keigoi/scribble-ocaml
 * This code should be compiled with scribble-ocaml-runtime
 * https://github.com/keigoi/scribble-ocaml-runtime *)


module Make (Session:Scribble.S.SESSION)  = struct
  type string = java.lang.String
  type int = java.lang.Integer

open Session

type ('c_A, 'c_S) travel1_C = ('c_A, 'c_S) travel1_C_1
and ('c_A, 'c_S) travel1_C_1 =
  [`connect of [`A of 'c_A * [`msg of unit data *
    ('c_A, 'c_S) travel1_C_2 sess]]]
and ('c_A, 'c_S) travel1_C_2 =
  [`send of
    [`A of 'c_A *
      [`query of string data *
        [`recv of [`A of 'c_A * [`quote of int data *
          ('c_A, 'c_S) travel1_C_2 sess]]] sess
      |`reject of unit data *
        [`close] sess
    |`S of 'c_S * [`msg of unit data *
      [`send of [`S of 'c_S * [`pay of string data *
        [`recv of [`S of 'c_S * [`confirm of int data *
          [`send of [`A of 'c_A * [`accpt of int data *
            [`close] sess]]] sess]]] sess]]] sess]]]
type ('c_C, 'c_S) travel1_A = ('c_C, 'c_S) travel1_A_1
and ('c_C, 'c_S) travel1_A_1 =
  [`accept of [`C of 'c_C * [`msg of unit data *
    ('c_C, 'c_S) travel1_A_2 sess]]]
and ('c_C, 'c_S) travel1_A_2 =
  [`recv of [`C of 'c_C *
    [`query of string data *
      [`send of [`C of 'c_C * [`quote of int data *
        ('c_C, 'c_S) travel1_A_2 sess]]] sess
    |`accpt of int data *
      [`close] sess
    |`reject of unit data *
      [`close] sess]]]
type ('c_C, 'c_A) travel1_S = ('c_C, 'c_A) travel1_S_1
and ('c_C, 'c_A) travel1_S_1 =
  [`accept of [`C of 'c_C * [`msg of unit data *
    [`recv of [`C of 'c_C * [`pay of string data *
      [`send of [`C of 'c_C * [`confirm of int data *
        [`close] sess]]] sess]]] sess]]]


module Shmem = Scribble.Shmem.Make(Session.LinIO.IO)(Session.Mutex)(Session.Condition)(Session.Endpoint)

type travel1 = ShmemMPSTChanenl__ of Shmem.MPSTChannel.t
let create_shmem_channel : unit -> travel1 = fun () ->
  ShmemMPSTChanenl__(Shmem.MPSTChannel.create ~acceptor_role:"role_C" ~connector_roles:["role_A";; "role_S"])


module C = struct
  let initiate : unit -> 'c. ('c, 'c, ('c_A, 'c_S) travel1_C sess) monad =
    fun () -> Internal.__initiate ~myname:"role_C"


  module A = struct
    module Make(X:sig
        type conn
        val conn : conn Endpoint.conn_kind
        val write_msg : conn -> [>`msg of unit data * 'p sess] -> unit io
        val write_query : conn -> [>`query of string data * 'p sess] -> unit io
        val write_reject : conn -> [>`reject of unit data * 'p sess] -> unit io
        val write_accpt : conn -> [>`accpt of int data * 'p sess] -> unit io
        val read_quote : conn -> [`quote of int data * 'p0] io
      end) = struct
      type conn = X.conn
      let role : ([>`A of X.conn * 'lab], X.conn, 'lab) role =
        {_pack_role=(fun labels -> `A(labels)) ; _repr="role_A"; _kind=X.conn}

      let msg : 'p. ([>`msg of unit data * 'p sess], X.conn, unit data * 'p sess) label =
        {_pack_label=(fun payload -> `msg(payload)); _send=X.write_msg}
      let query : 'p. ([>`query of string data * 'p sess], X.conn, string data * 'p sess) label =
        {_pack_label=(fun payload -> `query(payload)); _send=X.write_query}
      let reject : 'p. ([>`reject of unit data * 'p sess], X.conn, unit data * 'p sess) label =
        {_pack_label=(fun payload -> `reject(payload)); _send=X.write_reject}
      let accpt : 'p. ([>`accpt of int data * 'p sess], X.conn, int data * 'p sess) label =
        {_pack_label=(fun payload -> `accpt(payload)); _send=X.write_accpt}
      let receive_quote  : type p0. ([`quote of int data * p0], X.conn) labels =
        {_receive=X.read_quote}
    end

    module Raw = struct
      include Make(struct
          type conn = Shmem.Raw.t
          let conn = Shmem.MPSTChannel.Raw
          let write_msg = Shmem.Raw.send
          let write_query = Shmem.Raw.send
          let write_reject = Shmem.Raw.send
          let write_accpt = Shmem.Raw.send
          let read_quote = Shmem.Raw.receive
        end)
    end
  end
  module S = struct
    module Make(X:sig
        type conn
        val conn : conn Endpoint.conn_kind
        val write_msg : conn -> [>`msg of unit data * 'p sess] -> unit io
        val write_pay : conn -> [>`pay of string data * 'p sess] -> unit io
        val read_confirm : conn -> [`confirm of int data * 'p0] io
      end) = struct
      type conn = X.conn
      let role : ([>`S of X.conn * 'lab], X.conn, 'lab) role =
        {_pack_role=(fun labels -> `S(labels)) ; _repr="role_S"; _kind=X.conn}

      let msg : 'p. ([>`msg of unit data * 'p sess], X.conn, unit data * 'p sess) label =
        {_pack_label=(fun payload -> `msg(payload)); _send=X.write_msg}
      let pay : 'p. ([>`pay of string data * 'p sess], X.conn, string data * 'p sess) label =
        {_pack_label=(fun payload -> `pay(payload)); _send=X.write_pay}
      let receive_confirm  : type p0. ([`confirm of int data * p0], X.conn) labels =
        {_receive=X.read_confirm}
    end

    module Raw = struct
      include Make(struct
          type conn = Shmem.Raw.t
          let conn = Shmem.MPSTChannel.Raw
          let write_msg = Shmem.Raw.send
          let write_pay = Shmem.Raw.send
          let read_confirm = Shmem.Raw.receive
        end)
    end
  end

end

module A = struct
  let initiate : unit -> 'c. ('c, 'c, ('c_C, 'c_S) travel1_A sess) monad =
    fun () -> Internal.__initiate ~myname:"role_A"


  module C = struct
    module Make(X:sig
        type conn
        val conn : conn Endpoint.conn_kind
        val write_quote : conn -> [>`quote of int data * 'p sess] -> unit io
        val read_msg : conn -> [`msg of unit data * 'p0] io
        val read_query_or_accpt_or_reject : conn -> [`query of string data * 'p0|`accpt of int data * 'p1|`reject of unit data * 'p2] io
      end) = struct
      type conn = X.conn
      let role : ([>`C of X.conn * 'lab], X.conn, 'lab) role =
        {_pack_role=(fun labels -> `C(labels)) ; _repr="role_C"; _kind=X.conn}

      let quote : 'p. ([>`quote of int data * 'p sess], X.conn, int data * 'p sess) label =
        {_pack_label=(fun payload -> `quote(payload)); _send=X.write_quote}
      let receive_msg  : type p0. ([`msg of unit data * p0], X.conn) labels =
        {_receive=X.read_msg}
      let receive_query_or_accpt_or_reject  : type p0 p1 p2. ([`query of string data * p0|`accpt of int data * p1|`reject of unit data * p2], X.conn) labels =
        {_receive=X.read_query_or_accpt_or_reject}
    end

    module Raw = struct
      include Make(struct
          type conn = Shmem.Raw.t
          let conn = Shmem.MPSTChannel.Raw
          let write_quote = Shmem.Raw.send
          let read_msg = Shmem.Raw.receive
          let read_query_or_accpt_or_reject = Shmem.Raw.receive
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

module S = struct
  let initiate : unit -> 'c. ('c, 'c, ('c_C, 'c_A) travel1_S sess) monad =
    fun () -> Internal.__initiate ~myname:"role_S"


  module C = struct
    module Make(X:sig
        type conn
        val conn : conn Endpoint.conn_kind
        val write_confirm : conn -> [>`confirm of int data * 'p sess] -> unit io
        val read_msg : conn -> [`msg of unit data * 'p0] io
        val read_pay : conn -> [`pay of string data * 'p0] io
      end) = struct
      type conn = X.conn
      let role : ([>`C of X.conn * 'lab], X.conn, 'lab) role =
        {_pack_role=(fun labels -> `C(labels)) ; _repr="role_C"; _kind=X.conn}

      let confirm : 'p. ([>`confirm of int data * 'p sess], X.conn, int data * 'p sess) label =
        {_pack_label=(fun payload -> `confirm(payload)); _send=X.write_confirm}
      let receive_msg  : type p0. ([`msg of unit data * p0], X.conn) labels =
        {_receive=X.read_msg}
      let receive_pay  : type p0. ([`pay of string data * p0], X.conn) labels =
        {_receive=X.read_pay}
    end

    module Raw = struct
      include Make(struct
          type conn = Shmem.Raw.t
          let conn = Shmem.MPSTChannel.Raw
          let write_confirm = Shmem.Raw.send
          let read_msg = Shmem.Raw.receive
          let read_pay = Shmem.Raw.receive
        end)
    end
  end
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

end

end