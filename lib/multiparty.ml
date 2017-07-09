open Session
open Multiparty_base

type ('pre,'post,'v) monad = ('pre,'post,'v) Session.monad

let return x pre = pre, x
let (>>=) f g pre = match f pre with mid, x -> g x mid
let (>>) m n pre = match m pre with mid, x -> n mid

type empty = Empty
type ('p,'q,'pre,'post) slot = ('pre -> 'p) * ('pre -> 'q -> 'post)

type 'g channel = MChan.shared
type 'p sess = MChan.t
type 'r role = string
type ('br, 'dir, 'v, 'p) lab = {_pack: 'dir role * 'v -> 'br}

let __mkrole s = s

let new_channel = MChan.create  
               
let __connect : 'pre 'post. myname:string -> MChan.shared -> bindto:(empty,'p sess,'pre,'post) slot -> ('pre,'post,unit) monad =
  fun ~myname ch ~bindto:(get,put) pre ->
  let s = MChan.connect ch ~myname in
  put pre s, ()

let __accept : 'pre 'post. myname:string -> cli_count:int -> MChan.shared -> bindto:(empty,'p sess,'pre,'post) slot -> ('pre,'post,unit) monad =
  fun ~myname ~cli_count ch ~bindto:(get,put) pre ->
  let s = MChan.accept ch ~myname ~cli_count in
  put pre s, ()

let send
    : type br dir v p q pre post.
      ([`send of br] sess, p sess, pre, post) slot
      -> dir role
      -> (br, dir, v, p) lab
      -> v
      -> (pre, post, unit) monad
  = fun (get,put) dir {_pack} v pre ->
  let s = get pre in
  let uc = MChan.get_connection s ~othername:dir in
  UChan.send uc (_pack (dir,v));
  put pre s, ()

let recv
    : type br dir v p pre post.
      ([`recv of br] sess, p sess, pre, post) slot
      -> dir role
      -> (br, dir, v, p) lab
      -> (pre, post, v) monad = fun (get,put) dir {_pack} pre ->
  let s = get pre in
  let uc = MChan.get_connection s ~othername:dir in
  let msg = UChan.receive uc in
  let _, v = Obj.magic msg in (* FAIL *)
  put pre s, v

let close
    : type pre post.
      ([`close] sess, empty, pre, post) slot -> (pre, post, unit) monad =
  fun (_,put) pre ->
  put pre Empty, ()

module Syntax = struct
  let (>>=) = (>>=)
  module SessionN = struct
    let __receive
        :  type br dir p pre xx post v.
           ([`recv of br] sess, empty, pre, post) slot
           -> dir role
           -> (pre, post, br) monad =
      fun (get,put) dir pre ->
      let s = get pre in
      let uc = MChan.get_connection s ~othername:dir in
      let (br : br)(*polyvar*) = UChan.receive uc in
      put pre Empty, br
    
    let __set
        :  type br p v pre mid post.
           (empty, p sess, pre, post) slot
           -> p sess
           -> (pre, post, unit) monad =
      fun (get,put) p pre ->
      put pre p, ()
  end
end


(*
let ch = new_channel ()

let f () =       
  let%lin #a = connect ch `A in
  let%w x = a##recv `A `lab in
  a##send `A `Hello "World" >>
  a##close
 *)

type booking
type booking_C = booking_C_1
and booking_C_1 =
  [`send of
    [`Query of [`A] * string *
      [`recv of [`Quote of [`A] * int *
        booking_C_1]]
    |`Yes of [`A] * unit *
      [`send of
        [`Payment of [`S] * string *
          [`recv of [`Ack of [`S] * unit *
            booking_C_2]]]]
    |`No of [`A] * unit *
      booking_C_2]]
and booking_C_2 =
  [`send of
    [`Bye of [`A] * unit *
      [`close]]]
         
let msg_Query : type dir v p. ([`Query of dir * v * p], dir, v, p) lab =
  {_pack=(fun (dir,v) -> `Query(Obj.magic dir,v,Obj.magic ()))}

let agent : [`A] role = "agent"
let client : [`C] role = "client"
let server : [`S] role = "server"

let connect_C : 'pre 'post. booking channel -> bindto:(empty, booking_C sess, 'pre, 'post) slot -> ('pre,'post,unit) monad =
  fun ch ->
  __connect ~myname:"booking_C" ch

let connect_A ch = __connect ~myname:"booking_A" ch

let accept_S ch = __accept ~myname:"booking_S" ~cli_count:2 ch
  
