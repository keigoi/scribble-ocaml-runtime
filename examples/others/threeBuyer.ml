(* Generated from scribble-ocaml https://github.com/keigoi/scribble-ocaml
 * This code should be compiled with session-ocaml (multiparty)
 * https://github.com/keigoi/session-ocaml/tree/multiparty *)
open Multiparty
type threeBuyer

type threeBuyer_C = threeBuyer_C_1
and threeBuyer_C_1 = 
  [`recv of [`B] role * [`msg of int data *
    [`recv of [`B] role * [`msg of threebuyer.ThreeBuyer_TwoBuyerChoice_B.TwoBuyerChoice_B sess *
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
        [`msg of [`C] role * threebuyer.ThreeBuyer_TwoBuyerChoice_B.TwoBuyerChoice_B sess *
          [`recv of [`C] role *
            [`ok of unit data *
              [`close] sess
            |`quit of unit data *
              [`close] sess]] sess]] sess]]

let role_C : [`C] role = Internal.__mkrole "threeBuyer_C"
let role_B : [`B] role = Internal.__mkrole "threeBuyer_B"

let accept_B : 'pre 'post. (threeBuyer,[`ConnectFirst]) channel -> bindto:(empty, threeBuyer_B sess, 'pre, 'post) slot -> ('pre,'post,unit) monad =
  fun ch ->
  Internal.__accept ~myname:"threeBuyer_B" ~cli_count:1 ch

let connect_C : 'pre 'post. (threeBuyer,[`ConnectFirst]) channel -> bindto:(empty, threeBuyer_C sess, 'pre, 'post) slot -> ('pre,'post,unit) monad =
  fun ch ->
  Internal.__connect ~myname:"threeBuyer_C" ch

let new_channel_threeBuyer : unit -> (threeBuyer,[`ConnectFirst]) channel = new_channel
let msg_none = {_pack=(fun a -> `msg(a))}
let msg_quit = {_pack=(fun a -> `quit(a))}
let msg_ok = {_pack=(fun a -> `ok(a))}
