(* Generated from scribble-ocaml https://github.com/keigoi/scribble-ocaml
 * This code should be compiled with session-ocaml (multiparty)
 * https://github.com/keigoi/session-ocaml/tree/multiparty *)
open Multiparty
type travel1

type travel1_C = travel1_C_1
and travel1_C_1 = 
  [`send of
    [`msg of [`A] role connect * unit data *
      travel1_C_2 sess]]
and travel1_C_2 = 
  [`send of
    [`query of [`A] role * string data *
      [`recv of [`A] role * [`quote of int data *
        travel1_C_2 sess]] sess
    |`msg of [`S] role connect * unit data *
      [`send of
        [`pay of [`S] role * string data *
          [`recv of [`S] role * [`confirm of int data *
            [`send of
              [`accpt of [`A] role * int data *
                [`close] sess]] sess]] sess]] sess
    |`reject of [`A] role * unit data *
      [`close] sess]]
type travel1_A = travel1_A_1
and travel1_A_1 = 
  [`accept of [`C] role *
    [`msg of unit data *
      travel1_A_2 sess]]
and travel1_A_2 = 
  [`recv of [`C] role *
    [`query of string data *
      [`send of
        [`quote of [`C] role * int data *
          travel1_A_2 sess]] sess
    |`accpt of int data *
      [`close] sess
    |`reject of unit data *
      [`close] sess]]
type travel1_S = travel1_S_1
and travel1_S_1 = 
  [`accept of [`C] role *
    [`msg of unit data *
      [`recv of [`C] role * [`pay of string data *
        [`send of
          [`confirm of [`C] role * int data *
            [`close] sess]] sess]] sess]]

let role_C : [`C] role = Internal.__mkrole "role_C"
let role_A : [`A] role = Internal.__mkrole "role_A"
let role_S : [`S] role = Internal.__mkrole "role_S"

let initiate_C : 'pre 'post. (travel1,[`Explicit]) channel -> ('c, 'c, travel1_C sess) monad =
  fun ch ->
  Internal.__initiate ~myname:"role_C" ch
let initiate_A : 'pre 'post. (travel1,[`Explicit]) channel -> ('c, 'c, travel1_A sess) monad =
  fun ch ->
  Internal.__initiate ~myname:"role_A" ch
let initiate_S : 'pre 'post. (travel1,[`Explicit]) channel -> ('c, 'c, travel1_S sess) monad =
  fun ch ->
  Internal.__initiate ~myname:"role_S" ch

let new_channel_travel1 () : (travel1,[`Explicit]) channel = Internal.__new_connect_later_channel ["role_C";"role_A";"role_S"]
let msg_none = {_pack=(fun a -> `msg(a))}
let msg_accpt = {_pack=(fun a -> `accpt(a))}
let msg_confirm = {_pack=(fun a -> `confirm(a))}
let msg_pay = {_pack=(fun a -> `pay(a))}
let msg_query = {_pack=(fun a -> `query(a))}
let msg_quote = {_pack=(fun a -> `quote(a))}
let msg_reject = {_pack=(fun a -> `reject(a))}
