(* Generated from scribble-ocaml https://github.com/keigoi/scribble-ocaml
 * This code should be compiled with session-ocaml (multiparty)
 * https://github.com/keigoi/session-ocaml/tree/multiparty *)
open Multiparty
type discon

type discon_A = discon_A_1
and discon_A_1 = 
  [`send of
    [`msg of [`B] role connect * unit *
      discon_A_2]]
and discon_A_2 = 
  [`send of
    [`_1 of [`B] role * unit *
      discon_A_2
    |`_3 of [`B] role * unit *
      [`close]]]
type discon_B = discon_B_1
and discon_B_1 = 
  [`accept of
    [`msg of [`A] role * unit *
      discon_B_2]]
and discon_B_2 = 
  [`recv of
    [`_1 of [`A] role * unit *
      [`send of
        [`_2 of [`C] role connect * unit *
          [`disconnect of
            [`msg of [`C] role * unit *
              discon_B_2]]]]
    |`_3 of [`A] role * unit *
      [`close]]]
type discon_C = discon_C_1
and discon_C_1 = 
  [`accept of
    [`_2 of [`B] role * unit *
      [`disconnect of
        [`msg of [`B] role * unit *
          discon_C_1]]]]

let role_A : [`A] role = Internal.__mkrole "discon_A"
let role_B : [`B] role = Internal.__mkrole "discon_B"
let role_C : [`C] role = Internal.__mkrole "discon_C"

let initiate_A : 'pre 'post. (discon,[`ConnectLater]) channel -> bindto:(empty, discon_A sess, 'pre, 'post) slot -> ('pre,'post,unit) monad =
  fun ch ->
  Internal.__initiate ~myname:"discon_A" ch
let initiate_B : 'pre 'post. (discon,[`ConnectLater]) channel -> bindto:(empty, discon_B sess, 'pre, 'post) slot -> ('pre,'post,unit) monad =
  fun ch ->
  Internal.__initiate ~myname:"discon_B" ch
let initiate_C : 'pre 'post. (discon,[`ConnectLater]) channel -> bindto:(empty, discon_C sess, 'pre, 'post) slot -> ('pre,'post,unit) monad =
  fun ch ->
  Internal.__initiate ~myname:"discon_C" ch

let new_channel_discon () : (discon,[`ConnectLater]) channel = Internal.__new_connect_later_channel ["discon_A";"discon_B";"discon_C"]
let msg_none = {_pack=(fun a -> `msg(a))}
let msg_1 = {_pack=(fun a -> `_1(a))}
let msg_2 = {_pack=(fun a -> `_2(a))}
let msg_3 = {_pack=(fun a -> `_3(a))}
