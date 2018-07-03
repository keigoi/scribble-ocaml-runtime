module type CHAN = sig
  type +'a io
  type 'a t
  val create : unit -> 'a t
  val send : 'a t -> 'a -> unit io
  val receive : 'a t -> 'a io
end

module type DCHAN = sig
  include CHAN
  val reverse : 'a t -> 'a t
end

module type RAW_DCHAN = sig
  type +'a io
  type t
  val create : unit -> t
  val send : t -> 'a -> unit io
  val receive : t -> 'a io
  val reverse : t -> t
end

module type ENDPOINT = sig
  type +'a io
  type 'c key
  type 'c conn_kind = ..

  val create_key : 'c conn_kind -> string -> 'c key
  val string_of_key : 'c key -> string
  val kind_of_key : 'c key -> 'c conn_kind

  type 'c conn = {handle: 'c; close: unit -> unit io}
  type 'c connector = unit -> 'c conn io
  type 'c acceptor  = unit -> 'c conn io

  type t

  val create : myname:string -> t
  val close : t -> unit io
  val myname : t -> string

  val connect : t -> 'c key -> 'c connector -> unit io
  val disconnect : t -> 'c key -> unit io
  val accept : t -> 'c key -> 'c acceptor -> unit io
  val attach : t -> 'c key -> 'c conn -> unit
  val detach : t -> 'c key -> 'c conn
  val get_connection : t -> 'c key -> 'c conn
end

open Linocaml.Base

module type SESSION = sig
  type +'a io
  type ('p,'q,'a) monad

  module Endpoint : ENDPOINT with type 'a io = 'a io

  type 'a lin = 'a Linocaml.Base.lin
  type 'a data = 'a Linocaml.Base.data

  type 'p sess_
  type 'p sess = 'p sess_ lin

  type 'c connector
  type 'c acceptor

  type ('roles, 'conn, 'labels) role = {_pack_role: 'conn * 'labels -> 'roles; _repr:string; _kind:'conn Endpoint.conn_kind}
  type ('labels, 'conn, 'payloads) label = {_pack_label: 'payloads -> 'labels; _send:'conn -> 'labels -> unit io}
  type ('labels, 'conn) labels = {_receive:'conn -> 'labels io}

  val dummy : 'p sess

  val send :
        ([>] as 'roles, 'conn, ([>] as 'labels)) role *  ('labels, 'conn, 'v data * 'p sess) label * 'v
        -> ([`send of 'roles] sess, empty, 'p sess) monad

  val receive :
        ([>] as 'role, 'conn, ([>] as 'labels)) role * ('labels, 'conn) labels
        -> ([`recv of 'role] sess, empty, 'labels lin) monad

  val close : ([`close] sess, empty, unit lin) monad

  val deleg_send
      : ([>] as 'roles, 'conn, ([>] as 'labels)) role *  ('labels, 'conn, 'q sess * 'p sess) label
        -> ([`send of 'roles] sess * 'q sess, empty, 'p sess) monad

  val connect :
        'conn connector
        -> ([>] as 'roles, 'conn, ([>] as 'labels)) role *  ('labels, 'conn, 'v data * 'p sess) label * 'v
        -> ([`connect of 'roles] sess, empty, 'p sess) monad

  val accept :
        'conn acceptor
        -> ([>] as 'role, 'conn, ([>] as 'labels)) role * ('labels, 'conn) labels
        -> ([`accept of 'role] sess, empty, 'labels lin) monad

  val connect_corr :
        'conn connector
        -> ([>] as 'roles, 'conn, ([>] as 'labels)) role *  ('labels, 'conn * 'corr, 'v data * 'p sess) label * 'corr * 'v
        -> ([`connect of 'roles] sess, empty, 'p sess) monad

  val accept_corr :
        'conn acceptor
        -> ([>] as 'role, 'conn, ([>] as 'labels)) role * ('labels, 'conn * 'corr) labels * 'corr
        -> ([`accept of 'role] sess, empty, 'labels lin) monad

  val disconnect :
        ([>] as 'role, 'conn, 'p sess) role
        -> ([`disconnect of 'role] sess, empty, 'p sess) monad

  module Internal : sig
    val __initiate : myname:string -> ('x, 'x, 'p sess) monad
    val __create_connector : 'c Endpoint.connector -> 'c connector
    val __create_acceptor : 'c Endpoint.acceptor -> 'c acceptor
  end

end

module type TCP = sig
  module Endpoint : ENDPOINT
  type stream
  type _ Endpoint.conn_kind += Stream : stream Endpoint.conn_kind
  val connector : host:string -> port:int -> stream Endpoint.connector
  val new_domain_channel : unit -> (stream Endpoint.connector * stream Endpoint.acceptor) Endpoint.io
 end

module type RAW_MCHAN = sig
  module Endpoint : ENDPOINT
  type t
  type raw
  type _ Endpoint.conn_kind += Raw : raw Endpoint.conn_kind
  val create : acceptor_role:string -> connector_roles:string list -> t
  val accept : t -> Endpoint.t Endpoint.io
  val connect : t -> role:string -> Endpoint.t Endpoint.io
end
