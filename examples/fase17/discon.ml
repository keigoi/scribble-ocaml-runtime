(* Generated from scribble-ocaml https://github.com/keigoi/scribble-ocaml
 * This code should be compiled with session-ocaml (multiparty)
 * https://github.com/keigoi/session-ocaml/tree/multiparty *)
open Multiparty
type discon

type discon_A = discon_A_1
and discon_A_1 = 
  [`send of
    [`msg of [`B] role connect * unit data *
      discon_A_2 sess]]
and discon_A_2 = 
  [`send of
    [`_1 of [`B] role * unit data *
      discon_A_2 sess
    |`_3 of [`B] role * unit data *
      [`close] sess]]
type discon_B = discon_B_1
and discon_B_1 = 
  [`accept of [`A] role *
    [`msg of unit data *
      discon_B_2 sess]]
and discon_B_2 = 
  [`recv of [`A] role *
    [`_1 of unit data *
      [`send of
        [`_2 of [`C] role connect * unit data *
          [`disconnect of
            [`msg of [`C] role * unit data *
              discon_B_2 sess]] sess]] sess
    |`_3 of unit data *
      [`close] sess]]
type discon_C = discon_C_1
and discon_C_1 = 
  [`accept of [`B] role *
    [`_2 of unit data *
      [`disconnect of
        [`msg of [`B] role * unit data *
          discon_C_1 sess]] sess]]

let role_A : [`A] role = Internal.__mkrole "role_A"
let role_B : [`B] role = Internal.__mkrole "role_B"
let role_C : [`C] role = Internal.__mkrole "role_C"

let initiate_A : 'pre 'post. (discon,[`Explicit]) channel -> bindto:(empty, discon_A sess, 'pre, 'post) slot -> ('pre,'post,unit) monad =
  fun ch ->
  Internal.__initiate ~myname:"role_A" ch
let initiate_B : 'pre 'post. (discon,[`Explicit]) channel -> bindto:(empty, discon_B sess, 'pre, 'post) slot -> ('pre,'post,unit) monad =
  fun ch ->
  Internal.__initiate ~myname:"role_B" ch
let initiate_C : 'pre 'post. (discon,[`Explicit]) channel -> bindto:(empty, discon_C sess, 'pre, 'post) slot -> ('pre,'post,unit) monad =
  fun ch ->
  Internal.__initiate ~myname:"role_C" ch

let new_channel_discon () : (discon,[`Explicit]) channel = Internal.__new_connect_later_channel ["role_A";"role_B";"role_C"]
let msg_none = {_pack=(fun a -> `msg(a))}
let msg_1 = {_pack=(fun a -> `_1(a))}
let msg_2 = {_pack=(fun a -> `_2(a))}
let msg_3 = {_pack=(fun a -> `_3(a))}
