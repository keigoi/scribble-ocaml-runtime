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

type ('pre,'post,'a) monad = ('pre,'post,'a) Linocaml.monad
type ('a, 'pre,'post,'b) bind = ('a, 'pre,'post,'b) Linocaml.bind

val return : 'x -> ('p, 'p, 'x) monad
val (>>>==) : ('pre, 'mid, 'a) monad -> ('a, 'mid, 'post, 'b) bind -> ('pre, 'post, 'b) monad
val (>>=) : ('pre, 'mid, unit) monad -> (unit -> ('mid, 'post, 'b) monad) -> ('pre, 'post, 'b) monad
val (>>) : ('pre, 'mid, unit) monad -> ('mid, 'post, 'b) monad -> ('pre, 'post, 'b) monad

type ('a,'b,'pre,'post) slot = ('a,'b,'pre,'post) Lens.t
type empty = Linocaml.empty

val new_channel : unit -> ('g,[`Implicit]) channel
val new_lazy_channel : unit -> ('g,[`Implicit]) channel

val connect :
  ([ `send of 'br ] sess, 'p sess, 'pre, 'post) slot ->
  'dir role -> ('br, 'dir role connect * 'v data * 'p sess) lab -> 'v -> ('pre, 'post, unit) monad

(** invariant: 'br must be [`tag of 'a * 'b sess] *)
val accept :
  ([`accept of 'dir role * 'br] sess, empty, 'pre, 'post) slot
  -> 'dir role
  -> ('pre, 'post, 'br lin) Linocaml.monad

val disconnect :
  ([ `disconnect of 'br ] sess, 'p sess, 'pre, 'post) slot ->
  'dir role -> ('br, 'dir role * unit data * 'p sess) lab -> unit -> ('pre, 'post, unit) monad

(** invariant: 'br must be [`tag of 'a * 'b * 'c sess] *)
val send :
  ([ `send of 'br ] sess, 'p sess, 'pre, 'post) slot ->
  'dir role -> ('br, 'dir role * 'v data * 'p sess) lab -> 'v -> ('pre, 'post, unit) monad

(** invariant: 'br must be [`tag of 'a * 'b * 'c sess] *)
val deleg_send :
  ([ `send of 'br ] sess, 'p sess, 'pre, 'mid) slot ->
  'dir role -> ('br, 'dir role * 'q sess * 'p sess) lab ->
  ('q sess, empty, 'mid, 'post) slot ->
  ('pre, 'post, unit) monad

(** invariant: 'br must be [`tag of 'a * 'b sess] *)
val receive :
  ([`recv of 'dir role * 'br] sess, empty, 'pre, 'post) slot
  -> 'dir role
  -> ('pre, 'post, 'br lin) Linocaml.monad

val close :
  ([ `close ] sess, empty, 'pre, 'post) slot ->
  ('pre, 'post, unit) monad

module Internal : sig
  val __new_connect_later_channel : string list -> ('g,[`Explicit]) channel
  
  val __mkrole : string -> 'a role
  
  val __initiate :
    myname:string ->
    ('g,[`Explicit]) channel ->
    ('c, 'c, 'p sess) monad
  
  val __connect :
    myname:string ->
    ('g,[`Implicit]) channel ->
    ('c, 'c, 'p sess) monad
  
  val __accept :
    myname:string ->
    cli_count:int ->
    ('g,[`Implicit]) channel ->
    ('c, 'c, 'p sess) monad
end
