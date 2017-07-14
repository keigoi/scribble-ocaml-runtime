type ('g,'c) channel
type 'p sess
type 'r role
type ('br, 'payload) lab = {
    _pack : 'payload -> 'br
  }
type _raw_sess

type ('pre,'post,'a) monad
val return : 'x -> ('p, 'p, 'x) monad
val (>>=) : ('pre, 'mid, 'a) monad -> ('a -> ('mid, 'post, 'b) monad) -> ('pre, 'post, 'b) monad
val (>>) : ('pre, 'mid, 'a) monad -> ('mid, 'post, 'b) monad -> ('pre, 'post, 'b) monad
val _run_internal : 'a -> ('b -> ('a, 'a, 'c) monad) -> 'b -> 'c

type empty = Empty
type ('p,'q,'pre,'post) slot = ('pre -> 'p) * ('pre -> 'q -> 'post)

val new_channel : unit -> ('g,[`ConnectFirst]) channel

val connect :
  ([ `connect of 'br ] sess, 'p sess, 'pre, 'post) slot ->
  'dir role -> ('br, 'dir role * 'v * 'p) lab -> 'v -> ('pre, 'post, unit) monad

val disconnect :
  ([ `disconnect of 'br ] sess, 'p sess, 'pre, 'post) slot ->
  'dir role -> ('br, 'dir role * unit * 'p) lab -> unit -> ('pre, 'post, unit) monad

val send :
  ([ `send of 'br ] sess, 'p sess, 'pre, 'post) slot ->
  'dir role -> ('br, 'dir role * 'v * 'p) lab -> 'v -> ('pre, 'post, unit) monad

(* val recv : *)
(*   ([ `recv of 'br ] sess, 'p sess, 'pre, 'post) slot -> *)
(*   'dir role -> ('br, 'dir, 'v, 'p) lab -> ('pre, 'post, 'v) monad *)

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

module Syntax : sig
  val (>>=) : ('pre, 'mid, 'a) monad -> ('a -> ('mid, 'post, 'b) monad) -> ('pre, 'post, 'b) monad
  module SessionN : sig
    val __receive
        :  ([`recv of 'br] sess, empty, 'pre, 'post) slot
           -> 'dir role
           -> ('pre, 'post, 'br * _raw_sess) monad
    
    val __set
        :  (empty, 'p sess, 'pre, 'post) slot
           -> 'p * _raw_sess
           -> ('pre, 'post, unit) monad

    val __accept_receive
        :  ([`accept of 'br] sess, empty, 'pre, 'post) slot
           -> 'dir role
           -> ('pre, 'post, 'br * _raw_sess) monad  end
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
