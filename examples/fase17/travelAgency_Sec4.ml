(* Generated from scribble-ocaml https://github.com/keigoi/scribble-ocaml
 * This code should be compiled with session-ocaml (multiparty)
 * https://github.com/keigoi/session-ocaml/tree/multiparty *)
open Multiparty
type travelAgency

type travelAgency_C = travelAgency_C_1
and travelAgency_C_1 = 
  [`send of
    [`msg of [`A] role connect * unit data *
      travelAgency_C_2 sess]]
and travelAgency_C_2 = 
  [`send of
    [`query of [`A] role * str data *
      [`recv of [`A] role * [`quote of int data *
        travelAgency_C_2 sess]] sess
    |`accpt of [`A] role * unit data *
      [`recv of [`A] role * [`port of int data *
        [`send of
          [`pay of [`S] role connect * str data *
            [`recv of [`S] role * [`confirm of int data *
              [`close] sess]] sess]] sess]] sess
    |`reject of [`A] role * unit data *
      [`close] sess]]
type travelAgency_A = travelAgency_A_1
and travelAgency_A_1 = 
  [`accept of [`C] role *
    [`msg of unit data *
      travelAgency_A_2 sess]]
and travelAgency_A_2 = 
  [`recv of [`C] role *
    [`query of str data *
      [`send of
        [`quote of [`C] role * int data *
          travelAgency_A_2 sess]] sess
    |`accpt of unit data *
      [`send of
        [`msg of [`S] role connect * unit data *
          [`recv of [`S] role * [`port of int data *
            [`send of
              [`port of [`C] role * int data *
                [`close] sess]] sess]] sess]] sess
    |`reject of unit data *
      [`close] sess]]
type travelAgency_S = travelAgency_S_1
and travelAgency_S_1 = 
  [`accept of [`A] role *
    [`msg of unit data *
      [`send of
        [`port of [`A] role * int data *
          [`accept of [`C] role *
            [`pay of str data *
              [`send of
                [`confirm of [`C] role * int data *
                  [`close] sess]] sess]] sess]] sess]]

let role_C : [`C] role = Internal.__mkrole "travelAgency_C"
let role_A : [`A] role = Internal.__mkrole "travelAgency_A"
let role_S : [`S] role = Internal.__mkrole "travelAgency_S"

let initiate_C : 'pre 'post. (travelAgency,[`ConnectLater]) channel -> bindto:(empty, travelAgency_C sess, 'pre, 'post) slot -> ('pre,'post,unit) monad =
  fun ch ->
  Internal.__initiate ~myname:"travelAgency_C" ch
let initiate_A : 'pre 'post. (travelAgency,[`ConnectLater]) channel -> bindto:(empty, travelAgency_A sess, 'pre, 'post) slot -> ('pre,'post,unit) monad =
  fun ch ->
  Internal.__initiate ~myname:"travelAgency_A" ch
let initiate_S : 'pre 'post. (travelAgency,[`ConnectLater]) channel -> bindto:(empty, travelAgency_S sess, 'pre, 'post) slot -> ('pre,'post,unit) monad =
  fun ch ->
  Internal.__initiate ~myname:"travelAgency_S" ch

let new_channel_travelAgency () : (travelAgency,[`ConnectLater]) channel = Internal.__new_connect_later_channel ["travelAgency_C";"travelAgency_A";"travelAgency_S"]
let msg_none = {_pack=(fun a -> `msg(a))}
let msg_accpt = {_pack=(fun a -> `accpt(a))}
let msg_confirm = {_pack=(fun a -> `confirm(a))}
let msg_quote = {_pack=(fun a -> `quote(a))}
let msg_port = {_pack=(fun a -> `port(a))}
let msg_reject = {_pack=(fun a -> `reject(a))}
let msg_query = {_pack=(fun a -> `query(a))}
let msg_pay = {_pack=(fun a -> `pay(a))}
