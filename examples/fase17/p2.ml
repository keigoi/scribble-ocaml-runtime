(* Generated from scribble-ocaml https://github.com/keigoi/scribble-ocaml
 * This code should be compiled with session-ocaml (multiparty)
 * https://github.com/keigoi/session-ocaml/tree/multiparty *)
open Multiparty
type p2

type p2_A = p2_A_1
and p2_A_1 = 
  [`send of
    [`_1 of [`B] role connect * unit data *
      [`disconnect of
        [`msg of [`B] role * unit data *
          p2_A_1 sess]] sess
    |`_2 of [`C] role connect * unit data *
      [`disconnect of
        [`msg of [`C] role * unit data *
          p2_A_1 sess]] sess]]
type p2_B = p2_B_1
and p2_B_1 = 
  [`accept of [`A] role *
    [`_1 of unit data *
      [`disconnect of
        [`msg of [`A] role * unit data *
          p2_B_1 sess]] sess]]
type p2_C = p2_C_1
and p2_C_1 = 
  [`accept of [`A] role *
    [`_2 of unit data *
      [`disconnect of
        [`msg of [`A] role * unit data *
          p2_C_1 sess]] sess]]

let role_A : [`A] role = Internal.__mkrole "p2_A"
let role_B : [`B] role = Internal.__mkrole "p2_B"
let role_C : [`C] role = Internal.__mkrole "p2_C"

let initiate_A : 'pre 'post. (p2,[`ConnectLater]) channel -> bindto:(empty, p2_A sess, 'pre, 'post) slot -> ('pre,'post,unit) monad =
  fun ch ->
  Internal.__initiate ~myname:"p2_A" ch
let initiate_B : 'pre 'post. (p2,[`ConnectLater]) channel -> bindto:(empty, p2_B sess, 'pre, 'post) slot -> ('pre,'post,unit) monad =
  fun ch ->
  Internal.__initiate ~myname:"p2_B" ch
let initiate_C : 'pre 'post. (p2,[`ConnectLater]) channel -> bindto:(empty, p2_C sess, 'pre, 'post) slot -> ('pre,'post,unit) monad =
  fun ch ->
  Internal.__initiate ~myname:"p2_C" ch

let new_channel_p2 () : (p2,[`ConnectLater]) channel = Internal.__new_connect_later_channel ["p2_A";"p2_B";"p2_C"]
let msg_none = {_pack=(fun a -> `msg(a))}
let msg_1 = {_pack=(fun a -> `_1(a))}
let msg_2 = {_pack=(fun a -> `_2(a))}
