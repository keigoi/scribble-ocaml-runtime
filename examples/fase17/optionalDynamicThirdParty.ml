(* Generated from scribble-ocaml https://github.com/keigoi/scribble-ocaml
 * This code should be compiled with session-ocaml (multiparty)
 * https://github.com/keigoi/session-ocaml/tree/multiparty *)
open Multiparty
type optionalDynamicThirdParty

type optionalDynamicThirdParty_A = optionalDynamicThirdParty_A_1
and optionalDynamicThirdParty_A_1 = 
  [`send of
    [`hello of [`B] role connect * unit data *
      [`recv of [`B] role * [`goodday of unit data *
        [`send of
          [`opt1 of [`B] role * unit data *
            [`close] sess
          |`opt2 of [`B] role * unit data *
            [`close] sess]] sess]] sess]]
type optionalDynamicThirdParty_B = optionalDynamicThirdParty_B_1
and optionalDynamicThirdParty_B_1 = 
  [`accept of [`A] role *
    [`hello of unit data *
      [`send of
        [`goodday of [`A] role * unit data *
          [`recv of [`A] role *
            [`opt1 of unit data *
              [`send of
                [`greetings of [`C] role connect * unit data *
                  [`close] sess]] sess
            |`opt2 of unit data *
              [`close] sess]] sess]] sess]]
type optionalDynamicThirdParty_C = optionalDynamicThirdParty_C_1
and optionalDynamicThirdParty_C_1 = 
  [`accept of [`B] role *
    [`greetings of unit data *
      [`close] sess]]

let role_A : [`A] role = Internal.__mkrole "role_A"
let role_B : [`B] role = Internal.__mkrole "role_B"
let role_C : [`C] role = Internal.__mkrole "role_C"

let initiate_A : 'pre 'post. (optionalDynamicThirdParty,[`Explicit]) channel -> ('c, 'c, optionalDynamicThirdParty_A sess) monad =
  fun ch ->
  Internal.__initiate ~myname:"role_A" ch
let initiate_B : 'pre 'post. (optionalDynamicThirdParty,[`Explicit]) channel -> ('c, 'c, optionalDynamicThirdParty_B sess) monad =
  fun ch ->
  Internal.__initiate ~myname:"role_B" ch
let initiate_C : 'pre 'post. (optionalDynamicThirdParty,[`Explicit]) channel -> ('c, 'c, optionalDynamicThirdParty_C sess) monad =
  fun ch ->
  Internal.__initiate ~myname:"role_C" ch

let new_channel_optionalDynamicThirdParty () : (optionalDynamicThirdParty,[`Explicit]) channel = Internal.__new_connect_later_channel ["role_A";"role_B";"role_C"]
let msg_goodday = {_pack=(fun a -> `goodday(a))}
let msg_greetings = {_pack=(fun a -> `greetings(a))}
let msg_hello = {_pack=(fun a -> `hello(a))}
let msg_opt1 = {_pack=(fun a -> `opt1(a))}
let msg_opt2 = {_pack=(fun a -> `opt2(a))}
