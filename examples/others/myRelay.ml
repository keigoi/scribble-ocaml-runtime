(* Generated from scribble-ocaml https://github.com/keigoi/scribble-ocaml
 * This code should be compiled with session-ocaml (multiparty)
 * https://github.com/keigoi/session-ocaml/tree/multiparty *)
open Multiparty
type myRelay

type myRelay_A = myRelay_A_1
and myRelay_A_1 = 
  [`send of
    [`M of [`B] role * unit data *
      [`close] sess]]
type myRelay_B = myRelay_B_1
and myRelay_B_1 = 
  [`recv of [`A] role * [`M of unit data *
    [`send of
      [`M of [`C] role * unit data *
        [`close] sess]] sess]]
type myRelay_C = myRelay_C_1
and myRelay_C_1 = 
  [`recv of [`B] role * [`M of unit data *
    [`close] sess]]

let role_A : [`A] role = Internal.__mkrole "myRelay_A"
let role_B : [`B] role = Internal.__mkrole "myRelay_B"
let role_C : [`C] role = Internal.__mkrole "myRelay_C"

let accept_A : 'pre 'post. (myRelay,[`ConnectFirst]) channel -> bindto:(empty, myRelay_A sess, 'pre, 'post) slot -> ('pre,'post,unit) monad =
  fun ch ->
  Internal.__accept ~myname:"myRelay_A" ~cli_count:2 ch

let connect_B : 'pre 'post. (myRelay,[`ConnectFirst]) channel -> bindto:(empty, myRelay_B sess, 'pre, 'post) slot -> ('pre,'post,unit) monad =
  fun ch ->
  Internal.__connect ~myname:"myRelay_B" ch
let connect_C : 'pre 'post. (myRelay,[`ConnectFirst]) channel -> bindto:(empty, myRelay_C sess, 'pre, 'post) slot -> ('pre,'post,unit) monad =
  fun ch ->
  Internal.__connect ~myname:"myRelay_C" ch

let new_channel_myRelay : unit -> (myRelay,[`ConnectFirst]) channel = new_channel
let msg_M = {_pack=(fun a -> `M(a))}
