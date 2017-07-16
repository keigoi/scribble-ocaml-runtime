type ('g,'c) channel

type 'a data = 'a Linocaml.data
type 'a lin = 'a Linocaml.lin

type 'p sess_
type 'p sess = 'p sess_ lin

type 'a connect
type 'r role

type ('br, 'payload) lab = {
    _pack : 'payload -> 'br
  }
type _raw_sess

type ('pre,'post,'a) monad = ('pre,'post,'a) Linocaml.monad
val return : 'x -> ('p, 'p, 'x) monad
val (>>=) : ('pre, 'mid, 'a) monad -> ('a -> ('mid, 'post, 'b) monad) -> ('pre, 'post, 'b) monad
val (>>) : ('pre, 'mid, unit) monad -> ('mid, 'post, 'b) monad -> ('pre, 'post, 'b) monad

type ('a,'b,'pre,'post) slot = ('a,'b,'pre,'post) Lens.t
type empty = Linocaml.empty

val new_channel : unit -> ('g,[`ConnectFirst]) channel

val connect :
  ([ `send of 'br ] sess, 'p sess, 'pre, 'post) slot ->
  'dir role -> ('br, 'dir role connect * 'v data * 'p sess) lab -> 'v -> ('pre, 'post, unit) monad

val disconnect :
  ([ `disconnect of 'br ] sess, 'p sess, 'pre, 'post) slot ->
  'dir role -> ('br, 'dir role * unit * 'p sess) lab -> unit -> ('pre, 'post, unit) monad

(** invariant: 'br must be [`tag of 'a * 'b * 'c sess] *)
val send :
  ([ `send of 'br ] sess, 'p sess, 'pre, 'post) slot ->
  'dir role -> ('br, 'dir role * 'v data * 'p sess) lab -> 'v -> ('pre, 'post, unit) monad

(** invariant: 'br must be [`tag of 'a * 'b sess] *)
val receive :
  ([`recv of 'dir role * 'br] sess, empty, 'pre, 'post) slot
  -> 'dir role
  -> ('pre, 'post, 'br) Linocaml.lin_match

val close :
  ([ `close ] sess, empty, 'pre, 'post) slot ->
  ('pre, 'post, unit) monad

module Internal : sig
  val __new_connect_later_channel : string list -> ('g,[`ConnectLater]) channel
  
  val __mkrole : string -> 'a role
  
  val __initiate :
    myname:string ->
    ('g,[`ConnectLater]) channel ->
    bindto:(empty, 'p sess, 'pre, 'post) slot ->
    ('pre, 'post, unit) monad
  
  val __connect :
    myname:string ->
    ('g,[`ConnectFirst]) channel ->
    bindto:(empty, 'p sess, 'pre, 'post) slot ->
    ('pre, 'post, unit) monad
  
  val __accept :
    myname:string ->
    cli_count:int ->
    ('g,[`ConnectFirst]) channel ->
    bindto:(empty, 'p sess, 'pre, 'post) slot ->
    ('pre, 'post, unit) monad
end

(* val agent : [ `A ] role *)
(* val client : [ `C ] role *)
(* val server : [ `S ] role *)
  
(* val connect_C : *)
(*   booking channel -> *)
(*   bindto:(empty, booking_C sess, 'pre, 'post) slot -> *)
(*   ('pre, 'post, unit) monad *)
(* val connect_A : *)
(*   Multiparty_base.MChan.shared -> *)
(*   bindto:(empty, 'a sess, 'b, 'c) slot -> *)
(*   ('b, 'c, unit) monad *)
(* val accept_S : *)
(*   Multiparty_base.MChan.shared -> *)
(*   bindto:(empty, 'a sess, 'b, 'c) slot -> *)
(*   ('b, 'c, unit) monad *)
(* val msg_Query : ([> `Query of 'dir * 'v * 'p ], 'dir, 'v, 'p) lab *)
