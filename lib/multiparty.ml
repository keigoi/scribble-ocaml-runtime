open Session
open Multiparty_base

type ('pre,'post,'v) monad = ('pre,'post,'v) Session.monad

let return x pre = pre, x
let (>>=) f g pre = match f pre with mid, x -> g x mid
let (>>) m n pre = match m pre with mid, x -> n mid
let _run_internal a f x = snd (f x a)

type empty = Empty
type ('p,'q,'pre,'post) slot = ('pre -> 'p) * ('pre -> 'q -> 'post)

type 'g channel = MChan.shared
type 'p sess = MChan of MChan.t | Dummy
type _raw_sess = MChan.t

type 'r role = string
type ('br, 'payload) lab = {_pack: 'payload -> 'br}

let __mkrole s = s

let new_channel = MChan.create  
               
let __connect : 'pre 'post. myname:string -> MChan.shared -> bindto:(empty,'p sess,'pre,'post) slot -> ('pre,'post,unit) monad =
  fun ~myname ch ~bindto:(get,put) pre ->
  let s = MChan.connect ch ~myname in
  put pre (MChan s), ()

let __accept : 'pre 'post. myname:string -> cli_count:int -> MChan.shared -> bindto:(empty,'p sess,'pre,'post) slot -> ('pre,'post,unit) monad =
  fun ~myname ~cli_count ch ~bindto:(get,put) pre ->
  let s = MChan.accept ch ~myname ~cli_count in
  put pre (MChan s), ()

let send
    : type br dir v p q pre post.
      ([`send of br] sess, p sess, pre, post) slot
      -> dir role
      -> (br, dir role * v * p) lab
      -> v
      -> (pre, post, unit) monad
  = fun (get,put) dir {_pack} v pre ->
  let s = match get pre with MChan s -> s | Dummy -> failwith "no session -- malformed ppx expansion?? @ send" in
  print_endline (MChan.myname s ^ ": send to " ^ dir);
  let uc = MChan.get_connection s ~othername:dir in
  UChan.send uc (_pack (dir,v,Obj.magic Dummy));
  put pre (MChan s), ()

(* let recv *)
(*     : type br dir v p pre post. *)
(*       ([`recv of br] sess, p sess, pre, post) slot *)
(*       -> dir role *)
(*       -> (br, dir, v, p) lab *)
(*       -> (pre, post, v) monad = fun (get,put) dir {_pack} pre -> *)
(*   let s = get pre in *)
(*   let uc = MChan.get_connection s ~othername:dir in *)
(*   let msg = UChan.receive uc in *)
(*   let _, v = Obj.magic msg in (\* FAIL *\) *)
(*   put pre s, v *)

let close
    : type pre post.
      ([`close] sess, empty, pre, post) slot -> (pre, post, unit) monad =
  fun (get,put) pre ->
  let s = match get pre with MChan s -> s | Dummy -> failwith "no session -- malformed ppx?? @ close" in
  print_endline (MChan.myname s ^ ": close");
  put pre Empty, ()

module Syntax = struct
  let (>>=) = (>>=)
  module SessionN = struct
    let __receive
        :  type br dir p pre xx post v.
           ([`recv of br] sess, empty, pre, post) slot
           -> dir role
           -> (pre, post, br * _raw_sess) monad =
      fun (get,put) dir pre ->
      let s = match get pre with MChan s -> s | Dummy -> failwith "no session -- malformed ppx expansion??" in
      print_endline (MChan.myname s ^ ": receive from " ^ dir);
      let uc = MChan.get_connection s ~othername:dir in
      let (br : br)(*polyvar*) = UChan.receive uc in
      print_endline (MChan.myname s ^ ": received");
      put pre Empty, (br, s)
    
    let __set
        :  type br p v pre mid post.
           (empty, p sess, pre, post) slot
           -> p * _raw_sess
           -> (pre, post, unit) monad =
      fun (get,put) (_, p) pre ->
      put pre (MChan p), ()
  end
end

