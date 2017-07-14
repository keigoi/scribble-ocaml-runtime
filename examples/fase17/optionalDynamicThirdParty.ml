(* Generated from scribble-ocaml https://github.com/keigoi/scribble-ocaml
 * This code should be compiled with session-ocaml (multiparty)
 * https://github.com/keigoi/session-ocaml/tree/multiparty *)
open Multiparty
type optionalDynamicThirdParty

type optionalDynamicThirdParty_A = optionalDynamicThirdParty_A_1
and optionalDynamicThirdParty_A_1 = 
  [`connect of
    [`hello of [`B] role * unit *
      [`recv of [`goodday of [`B] role * unit *
        [`send of
          [`opt1 of [`B] role * unit *
            [`close]
          |`opt2 of [`B] role * unit *
            [`close]]]]]]]
type optionalDynamicThirdParty_B = optionalDynamicThirdParty_B_1
and optionalDynamicThirdParty_B_1 = 
  [`accept of
    [`hello of [`A] role * unit *
      [`send of
        [`goodday of [`A] role * unit *
          [`recv of
            [`opt1 of [`A] role * unit *
              [`connect of
                [`greetings of [`C] role * unit *
                  [`close]]]
            |`opt2 of [`A] role * unit *
              [`close]]]]]]]
type optionalDynamicThirdParty_C = optionalDynamicThirdParty_C_1
and optionalDynamicThirdParty_C_1 = 
  [`accept of
    [`greetings of [`B] role * unit *
      [`close]]]

let role_A : [`A] role = Internal.__mkrole "optionalDynamicThirdParty_A"
let role_B : [`B] role = Internal.__mkrole "optionalDynamicThirdParty_B"
let role_C : [`C] role = Internal.__mkrole "optionalDynamicThirdParty_C"

let initiate_A : 'pre 'post. (optionalDynamicThirdParty,[`ConnectLater]) channel -> bindto:(empty, optionalDynamicThirdParty_A sess, 'pre, 'post) slot -> ('pre,'post,unit) monad =
  fun ch ->
  Internal.__initiate ~myname:"optionalDynamicThirdParty_A" ch
let initiate_B : 'pre 'post. (optionalDynamicThirdParty,[`ConnectLater]) channel -> bindto:(empty, optionalDynamicThirdParty_B sess, 'pre, 'post) slot -> ('pre,'post,unit) monad =
  fun ch ->
  Internal.__initiate ~myname:"optionalDynamicThirdParty_B" ch
let initiate_C : 'pre 'post. (optionalDynamicThirdParty,[`ConnectLater]) channel -> bindto:(empty, optionalDynamicThirdParty_C sess, 'pre, 'post) slot -> ('pre,'post,unit) monad =
  fun ch ->
  Internal.__initiate ~myname:"optionalDynamicThirdParty_C" ch

let new_channel_optionalDynamicThirdParty () : (optionalDynamicThirdParty,[`ConnectLater]) channel = Internal.__new_connect_later_channel ["optionalDynamicThirdParty_A";"optionalDynamicThirdParty_B";"optionalDynamicThirdParty_C"]
let msg_goodday = {_pack=(fun a -> `goodday(a))}
let msg_opt1 = {_pack=(fun a -> `opt1(a))}
let msg_hello = {_pack=(fun a -> `hello(a))}
let msg_opt2 = {_pack=(fun a -> `opt2(a))}
let msg_greetings = {_pack=(fun a -> `greetings(a))}
