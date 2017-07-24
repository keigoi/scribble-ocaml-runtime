(* Generated from scribble-ocaml https://github.com/keigoi/scribble-ocaml
 * This code should be compiled with scribble-ocaml-runtime
 * https://github.com/keigoi/scribble-ocaml-runtime *)
open Multiparty
type travelAgency_Sec2

type travelAgency_Sec2_C = travelAgency_Sec2_C_1
and travelAgency_Sec2_C_1 = 
  [`send of
    [`msg of [`A] role connect * unit data *
      travelAgency_Sec2_C_2 sess]]
and travelAgency_Sec2_C_2 = 
  [`send of
    [`query of [`A] role * string data *
      [`recv of [`A] role * [`quote of int data *
        travelAgency_Sec2_C_2 sess]] sess
    |`pay of [`S] role connect * string data *
      [`recv of [`S] role * [`confirm of int data *
        [`send of
          [`accpt of [`A] role * int data *
            [`close] sess]] sess]] sess
    |`reject of [`A] role * unit data *
      [`close] sess]]
type travelAgency_Sec2_A = travelAgency_Sec2_A_1
and travelAgency_Sec2_A_1 = 
  [`accept of [`C] role *
    [`msg of unit data *
      travelAgency_Sec2_A_2 sess]]
and travelAgency_Sec2_A_2 = 
  [`recv of [`C] role *
    [`query of string data *
      [`send of
        [`quote of [`C] role * int data *
          travelAgency_Sec2_A_2 sess]] sess
    |`accpt of int data *
      [`close] sess
    |`reject of unit data *
      [`close] sess]]
type travelAgency_Sec2_S = travelAgency_Sec2_S_1
and travelAgency_Sec2_S_1 = 
  [`accept of [`C] role *
    [`pay of string data *
      [`send of
        [`confirm of [`C] role * int data *
          [`close] sess]] sess]]

let role_C : [`C] role = Internal.__mkrole "role_C"
let role_A : [`A] role = Internal.__mkrole "role_A"
let role_S : [`S] role = Internal.__mkrole "role_S"

let initiate_C : 'pre 'post. (travelAgency_Sec2,[`Explicit]) channel -> ('c, 'c, travelAgency_Sec2_C sess) monad =
  fun ch ->
  Internal.__initiate ~myname:"role_C" ch
let initiate_A : 'pre 'post. (travelAgency_Sec2,[`Explicit]) channel -> ('c, 'c, travelAgency_Sec2_A sess) monad =
  fun ch ->
  Internal.__initiate ~myname:"role_A" ch
let initiate_S : 'pre 'post. (travelAgency_Sec2,[`Explicit]) channel -> ('c, 'c, travelAgency_Sec2_S sess) monad =
  fun ch ->
  Internal.__initiate ~myname:"role_S" ch

let new_channel_travelAgency_Sec2 () : (travelAgency_Sec2,[`Explicit]) channel = Internal.__new_connect_later_channel ["role_C";"role_A";"role_S"]
let msg_none = {_pack=(fun a -> `msg(a))}
let msg_accpt = {_pack=(fun a -> `accpt(a))}
let msg_confirm = {_pack=(fun a -> `confirm(a))}
let msg_pay = {_pack=(fun a -> `pay(a))}
let msg_query = {_pack=(fun a -> `query(a))}
let msg_quote = {_pack=(fun a -> `quote(a))}
let msg_reject = {_pack=(fun a -> `reject(a))}
