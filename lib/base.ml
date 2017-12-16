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

  exception AcceptAgain

  module Sender : sig
    type ('c,'v) t = ('c -> 'v -> unit io, [%imp Senders]) Ppx_implicits.t
  end
  module Receiver : sig
    type ('c,'v) t = ('c -> 'v io, [%imp Receivers]) Ppx_implicits.t
  end

  type shmem_chan
  type 'c Endpoint.conn_kind += Shmem : shmem_chan Endpoint.conn_kind
  module Senders : sig
    val _f : shmem_chan -> 'v -> unit io
  end
  module Receivers : sig
    val _f : shmem_chan -> 'v io
  end

  type 'a lin = 'a Linocaml.Base.lin
  type 'a data = 'a Linocaml.Base.data

  type ('r,'c) role

  type 'p sess_
  type 'p sess = 'p sess_ lin
  type 'a connect

  val dummy : 'p sess

  type ('br, 'payload) lab = {
      _pack : 'payload -> 'br
    }

  (** invariant: 'br must be [`tag of 'a * 'b * 'c sess] *)
  val send :
    ?_sender:('c,'br) Sender.t
    -> ([ `send of 'br ] sess, empty, 'pre, 'post) slot
    -> ('dir,'c) role
    -> ('br, ('dir,'c) role * 'v data * 'p sess) lab
    -> 'v
    -> ('pre, 'post, 'p sess) monad

  (** invariant: 'br must be [`tag of 'a * 'b * 'c sess] *)
  val deleg_send :
    ?_sender:('c,'br) Sender.t
    -> ([ `send of 'br ] sess, 'p sess, 'pre, 'mid) slot
    -> ('dir,'c) role -> ('br, ('dir,'c) role * 'q sess * 'p sess) lab
    -> ('q sess, empty, 'mid, 'post) slot
    -> ('pre, 'post, unit lin) monad

  (** invariant: 'br must be [`tag of 'a * 'b sess] *)
  val receive :
    ?_receiver:('c, 'br) Receiver.t
    -> ([`recv of ('dir,'c) role * 'br] sess, empty, 'pre, 'post) slot
    -> ('dir,'c) role
    -> ('pre, 'post, 'br lin) monad

  val close :
    ([ `close ] sess, empty, 'pre, 'post) slot
    -> ('pre, 'post, unit lin) monad

  val connect :
    ?_sender:('c,'br) Sender.t
    -> ([ `send of 'br ] sess, empty, 'pre, 'post) slot
    -> 'c Endpoint.connector
    -> ('dir,'c) role
    -> ('br, ('dir,'c) role connect * 'v data * 'p sess) lab
    -> 'v
    -> ('pre, 'post, 'p sess) monad

  (** invariant: 'br must be [`tag of 'a * 'b sess] *)
  val accept :
    ?_receiver:('c, 'br) Receiver.t
    -> ([`accept of ('dir,'c) role * 'br] sess, empty, 'pre, 'post) slot
    -> 'c Endpoint.acceptor
    -> ('dir,'c) role
    -> ('pre, 'post, 'br lin) monad

  (**
   * accept_corr : accept with 'session correlation' [FASE17]
   * invariant: 'br must be [`tag of 'a * 'b sess]
   *)
  val accept_corr :
    ?_receiver:('c * 'corr, 'br) Receiver.t
    -> ([`accept of ('dir,'c) role * 'br] sess, empty, 'pre, 'post) slot
    -> 'c Endpoint.acceptor
    -> ('dir,'c) role
    -> 'corr
    -> ('pre, 'post, 'br lin) monad

  val disconnect :
    ([ `disconnect of ('dir,'c) role * 'p sess] sess, empty, 'pre, 'post) slot
    -> ('dir,'c) role
    -> ('pre, 'post, 'p sess) monad

  val attach :
    ('p sess, 'p sess, 'ss, 'ss) slot
    -> ('r,'c) role
    -> 'c Endpoint.conn
    -> ('ss, 'ss, unit lin) monad

  val detach :
    ('p sess, 'p sess, 'ss, 'ss) slot
    -> ('r,'c) role
    -> ('ss, 'ss, 'c Endpoint.conn data lin) monad

  module Shmem : sig
    type 'g channel
    val create_channel : roles:string list -> 'g channel
  end

  module Internal : sig
    val __mkrole : 'c Endpoint.conn_kind -> string -> ('r,'c) role
    val __accept : 'g Shmem.channel -> ('r, shmem_chan) role -> ('ss, 'ss, 'p sess) monad
    val __connect : 'g Shmem.channel -> ('r, shmem_chan) role -> ('ss, 'ss, 'p sess) monad
    val __initiate : myname:string -> ('c, 'c, 'p sess) monad
  end
end

module type TCP = sig
  module Endpoint : ENDPOINT
  type stream
  type _ Endpoint.conn_kind += Stream : stream Endpoint.conn_kind
  val connector : host:string -> port:int -> stream Endpoint.connector
  val new_domain_channel : unit -> (stream Endpoint.connector * stream Endpoint.acceptor) Endpoint.io
end
