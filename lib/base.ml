
type ('br, 'payload) lab = {
    _pack : 'payload -> 'br
  }

module type ENDPOINT = sig
  module LinIO : Linocaml.Base.LIN_IO
  module IO = LinIO.IO
            
  type 'c conn = {conn : 'c;
                  send    : 'a. 'c -> 'a -> unit IO.io;
                  receive : 'a. 'c -> 'a IO.io;
                  close   : 'c -> unit IO.io}

  type 'c connector = unit -> 'c conn IO.io
  type 'c acceptor  = unit -> 'c conn IO.io

  type 'c rolekind
  type 'c role
  val string_of_role : 'c conn role -> string
  val make_role : 'c rolekind -> string -> 'c conn role

  type t
  val init : string -> t IO.io
  val myname : t -> string
  val connect : t -> 'c conn role -> 'c connector -> unit IO.io
  val accept : t -> 'c conn role -> 'c acceptor -> unit IO.io
  val attach : t -> 'c conn role -> 'c conn -> unit
  val detach : t -> 'c conn role -> 'c conn
  val get_connection : t -> otherrole:'c conn role -> 'c conn
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
