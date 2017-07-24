(* Generated from scribble-ocaml https://github.com/keigoi/scribble-ocaml
 * This code should be compiled with scribble-ocaml-runtime
 * https://github.com/keigoi/scribble-ocaml-runtime *)
open Multiparty
type threeBuyer

type threeBuyer_C = threeBuyer_C_1
and threeBuyer_C_1 = 
  [`recv of [`B] role * [`msg of int data *
    [`recv of [`B] role * [`msg of TwoBuyerChoice.twoBuyerChoice_B sess *
      [`send of
        [`ok of [`B] role * unit data *
          [`close] sess
        |`quit of [`B] role * unit data *
          [`close] sess]] sess]] sess]]
type threeBuyer_B = threeBuyer_B_1
and threeBuyer_B_1 = 
  [`send of
    [`msg of [`C] role * int data *
      [`send of
        [`msg of [`C] role * TwoBuyerChoice.twoBuyerChoice_B sess *
          [`recv of [`C] role *
            [`ok of unit data *
              [`close] sess
            |`quit of unit data *
              [`close] sess]] sess]] sess]]

let role_C : [`C] role = Internal.__mkrole "role_C"
let role_B : [`B] role = Internal.__mkrole "role_B"

let accept_B : 'pre 'post. (threeBuyer,[`Implicit]) channel -> ('c, 'c, threeBuyer_B sess) monad =
  fun ch ->
  Internal.__accept ~myname:"role_B" ~cli_count:1 ch

let connect_C : 'pre 'post. (threeBuyer,[`Implicit]) channel -> ('c, 'c, threeBuyer_C sess) monad =
  fun ch ->
  Internal.__connect ~myname:"role_C" ch

let new_channel_threeBuyer : unit -> (threeBuyer,[`Implicit]) channel = new_channel
let msg_none = {_pack=(fun a -> `msg(a))}
let msg_ok = {_pack=(fun a -> `ok(a))}
let msg_quit = {_pack=(fun a -> `quit(a))}
