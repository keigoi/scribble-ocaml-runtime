(* Generated from scribble-ocaml https://github.com/keigoi/scribble-ocaml
 * This code should be compiled with session-ocaml (multiparty)
 * https://github.com/keigoi/session-ocaml/tree/multiparty *)
open Multiparty
type travel_Sec3

type travel_Sec3_C = travel_Sec3_C_1
and travel_Sec3_C_1 = 
  [`send of
    [`msg of [`A] role connect * unit data *
      travel_Sec3_C_2 sess]]
and travel_Sec3_C_2 = 
  [`send of
    [`query of [`A] role * unit data *
      [`recv of [`A] role * [`quote of unit data *
        travel_Sec3_C_2 sess]] sess
    |`pay of [`S] role connect * unit data *
      [`recv of [`S] role * [`confirm of unit data *
        [`send of
          [`accpt of [`A] role * unit data *
            [`close] sess]] sess]] sess
    |`reject of [`A] role * unit data *
      [`close] sess]]
type travel_Sec3_A = travel_Sec3_A_1
and travel_Sec3_A_1 = 
  [`accept of [`C] role *
    [`msg of unit data *
      travel_Sec3_A_2 sess]]
and travel_Sec3_A_2 = 
  [`recv of [`C] role *
    [`query of unit data *
      [`send of
        [`quote of [`C] role * unit data *
          travel_Sec3_A_2 sess]] sess
    |`accpt of unit data *
      [`close] sess
    |`reject of unit data *
      [`close] sess]]
type travel_Sec3_S = travel_Sec3_S_1
and travel_Sec3_S_1 = 
  [`accept of [`C] role *
    [`pay of unit data *
      [`send of
        [`confirm of [`C] role * unit data *
          [`close] sess]] sess]]

let role_C : [`C] role = Internal.__mkrole "role_C"
let role_A : [`A] role = Internal.__mkrole "role_A"
let role_S : [`S] role = Internal.__mkrole "role_S"

let initiate_C : 'pre 'post. (travel_Sec3,[`Explicit]) channel -> bindto:(empty, travel_Sec3_C sess, 'pre, 'post) slot -> ('pre,'post,unit) monad =
  fun ch ->
  Internal.__initiate ~myname:"role_C" ch
let initiate_A : 'pre 'post. (travel_Sec3,[`Explicit]) channel -> bindto:(empty, travel_Sec3_A sess, 'pre, 'post) slot -> ('pre,'post,unit) monad =
  fun ch ->
  Internal.__initiate ~myname:"role_A" ch
let initiate_S : 'pre 'post. (travel_Sec3,[`Explicit]) channel -> bindto:(empty, travel_Sec3_S sess, 'pre, 'post) slot -> ('pre,'post,unit) monad =
  fun ch ->
  Internal.__initiate ~myname:"role_S" ch

let new_channel_travel_Sec3 () : (travel_Sec3,[`Explicit]) channel = Internal.__new_connect_later_channel ["role_C";"role_A";"role_S"]
let msg_none = {_pack=(fun a -> `msg(a))}
let msg_accpt = {_pack=(fun a -> `accpt(a))}
let msg_confirm = {_pack=(fun a -> `confirm(a))}
let msg_pay = {_pack=(fun a -> `pay(a))}
let msg_query = {_pack=(fun a -> `query(a))}
let msg_quote = {_pack=(fun a -> `quote(a))}
let msg_reject = {_pack=(fun a -> `reject(a))}
