
type role = string
          
type ('br, 'payload) lab = {
    _pack : 'payload -> 'br
  }

module type BINARY = sig
  type +'a io
  type t
  val send : t -> 'a -> unit io
  val receive : t -> 'a io
  val close : t -> unit io
end

module type BINARY_CONN = sig
  module Binary : BINARY
  val conn : Binary.t
end

module type ENDPOINT = sig
  module LinIO : Linocaml.Base.LIN_IO
  module IO = LinIO.IO
       
  module type BINARY_CONN = BINARY_CONN with type 'a Binary.io = 'a IO.io
  type conn = (module BINARY_CONN)

  type 'g connector = unit -> conn IO.io
  type 'g acceptor  = unit -> conn IO.io

  type t = {self: role; role2bin : (string, conn) Hashtbl.t}
  val init : role -> t IO.io
  val myname : t -> role
  val connect : t -> role -> 'g connector -> unit IO.io
  val accept : t -> role -> 'g acceptor -> unit IO.io
  val attach : t -> role -> conn -> unit
  val detach : t -> role -> conn
  val get_connection : t -> othername:role -> conn
end

open Linocaml.Base

module type SESSION = sig
  module Endpoint : ENDPOINT
  module LinIO = Endpoint.LinIO
                  
  type 'a lin = 'a Linocaml.Base.lin
  type 'a data = 'a Linocaml.Base.data

  type 'r role
  type 'p sess_
  type 'p sess = 'p sess_ lin
  type 'a connect     
     
  (** invariant: 'br must be [`tag of 'a * 'b * 'c sess] *)
  val send :
    ([ `send of 'br ] sess, 'p sess, 'pre, 'post) slot ->
    'dir role -> ('br, 'dir role * 'v data * 'p sess) lab -> 'v -> ('pre, 'post, unit) LinIO.monad

  (** invariant: 'br must be [`tag of 'a * 'b * 'c sess] *)
  val deleg_send :
    ([ `send of 'br ] sess, 'p sess, 'pre, 'mid) slot ->
    'dir role -> ('br, 'dir role * 'q sess * 'p sess) lab ->
    ('q sess, empty, 'mid, 'post) slot ->
    ('pre, 'post, unit) LinIO.monad

  (** invariant: 'br must be [`tag of 'a * 'b sess] *)
  val receive :
    ([`recv of 'dir role * 'br] sess, empty, 'pre, 'post) slot
    -> 'dir role
    -> ('pre, 'post, 'br lin) LinIO.monad

  val close :
    ([ `close ] sess, empty, 'pre, 'post) slot ->
    ('pre, 'post, unit) LinIO.monad

  val connect :
    ([ `send of 'br ] sess, 'p sess, 'pre, 'post) slot ->
    'g Endpoint.connector ->
    'dir role -> ('br, 'dir role connect * 'v data * 'p sess) lab -> 'v -> ('pre, 'post, unit) LinIO.monad

  (** invariant: 'br must be [`tag of 'a * 'b sess] *)
  val accept :
    ([`accept of 'dir role * 'br] sess, empty, 'pre, 'post) slot
    -> 'g Endpoint.acceptor
    -> 'dir role
    -> ('pre, 'post, 'br lin) LinIO.monad

  val disconnect :
    ([ `disconnect of 'br ] sess, 'p sess, 'pre, 'post) slot ->
    'dir role -> ('br, 'dir role * unit data * 'p sess) lab -> unit -> ('pre, 'post, unit) LinIO.monad

  module Internal : sig
    (* val __new_connect_later_channel : string list -> ('g,[`Explicit]) channel *)
      
    val __mkrole : string -> 'a role
      
    val __connect :
      myname:string ->
      roles:string list ->
      'g Endpoint.connector ->
      ('c, 'c, 'p sess) Endpoint.LinIO.monad
      
    val __accept :
      myname:string ->
      roles:string list ->
      'g Endpoint.acceptor ->
      ('c, 'c, 'p sess) Endpoint.LinIO.monad
      
    (* val __initiate : *)
    (*   myname:string -> *)
    (*   ('g,[`Explicit]) channel -> *)
    (*   ('c, 'c, 'p sess) monad *)
  end
end
