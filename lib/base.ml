
module type ENDPOINT = sig
  module LinIO : Linocaml.Base.LIN_IO
  module IO = LinIO.IO

  type 'c connector = unit -> 'c IO.io
  type 'c acceptor  = unit -> 'c IO.io

  type 'c rolekind
  type 'c role
  val string_of_role : 'c role -> string
  val make_role : 'c rolekind -> string -> 'c role

  type t
  val init : string -> t IO.io
  val myname : t -> string
  val connect : t -> 'c role -> 'c connector -> unit IO.io
  val accept : t -> 'c role -> 'c acceptor -> unit IO.io
  val attach : t -> 'c role -> 'c -> unit
  val detach : t -> 'c role -> 'c
  val get_connection : t -> otherrole:'c role -> 'c
end

open Linocaml.Base


module type SESSION = sig
  module Endpoint : ENDPOINT
  module LinIO = Endpoint.LinIO
  module IO = LinIO.IO

  module Sender : sig
    type ('c,'v) t
    val pack_opt : _d:('c -> 'v -> unit IO.io) -> ('c,'v) t option
    [%%imp_spec opened Senders]
  end
  module Receiver : sig
    type ('c,'v) t
    val pack_opt : _d:('c -> 'v IO.io) -> ('c,'v) t option
    [%%imp_spec opened Receivers]
  end
            
  type 'a lin = 'a Linocaml.Base.lin
  type 'a data = 'a Linocaml.Base.data

  type ('r,'c) role = 'c Endpoint.role
  type 'p sess_
  type 'p sess = 'p sess_ lin
  type 'a connect

  type ('br, 'payload) lab = {
      _pack : 'payload -> 'br
    }
                           
  (** invariant: 'br must be [`tag of 'a * 'b * 'c sess] *)
  val send :
    ?_sender:('c,'br) Sender.t ->
    ([ `send of 'br ] sess, 'p sess, 'pre, 'post) slot ->
    ('dir,'c) role -> ('br, ('dir,'c) role * 'v data * 'p sess) lab -> 'v -> ('pre, 'post, unit) LinIO.monad

  (** invariant: 'br must be [`tag of 'a * 'b * 'c sess] *)
  val deleg_send :
    ?_sender:('c,'br) Sender.t ->
    ([ `send of 'br ] sess, 'p sess, 'pre, 'mid) slot ->
    ('dir,'c) role -> ('br, ('dir,'c) role * 'q sess * 'p sess) lab ->
    ('q sess, empty, 'mid, 'post) slot ->
    ('pre, 'post, unit) LinIO.monad

  (** invariant: 'br must be [`tag of 'a * 'b sess] *)
  val receive :
    ?_receiver:('c, 'br) Receiver.t ->
    ([`recv of ('dir,'c) role * 'br] sess, empty, 'pre, 'post) slot
    -> ('dir,'c) role
    -> ('pre, 'post, 'br lin) LinIO.monad

  val close :
    ([ `close ] sess, empty, 'pre, 'post) slot ->
    ('pre, 'post, unit) LinIO.monad

  val connect :
    ?_sender:('c,'br) Sender.t ->
    ([ `send of 'br ] sess, 'p sess, 'pre, 'post) slot ->
    'c Endpoint.connector ->
    ('dir,'c) role -> ('br, ('dir,'c) role connect * 'v data * 'p sess) lab -> 'v -> ('pre, 'post, unit) LinIO.monad

  (** invariant: 'br must be [`tag of 'a * 'b sess] *)
  val accept :
    ?_receiver:('c, 'br) Receiver.t ->
    ([`accept of ('dir,'c) role * 'br] sess, empty, 'pre, 'post) slot
    -> 'c Endpoint.acceptor
    -> ('dir,'c) role
    -> ('pre, 'post, 'br lin) LinIO.monad

  val disconnect :
    ([ `disconnect of 'br ] sess, 'p sess, 'pre, 'post) slot ->
    ('dir,'c) role -> ('br, ('dir,'c) role * unit data * 'p sess) lab -> unit -> ('pre, 'post, unit) LinIO.monad

  module Internal : sig
    (* val __new_connect_later_channel : string list -> ('g,[`Explicit]) channel *)
      
    val __mkrole : 'c Endpoint.rolekind -> string -> ('a,'c) role
      
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
