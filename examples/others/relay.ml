(* Generated from scribble-ocaml https://github.com/keigoi/scribble-ocaml
 * This code should be compiled with session-ocaml (multiparty)
 * https://github.com/keigoi/session-ocaml/tree/multiparty *)
open Multiparty
type relay

type relay_R1 = relay_R1_1
and relay_R1_1 = 
  [`send of
    [`M1 of [`R2] role * unit data *
      [`close] sess]]
type relay_R2 = relay_R2_1
and relay_R2_1 = 
  [`recv of [`R1] role * [`M1 of unit data *
    [`send of
      [`M2 of [`R3] role * unit data *
        [`close] sess]] sess]]
type relay_R3 = relay_R3_1
and relay_R3_1 = 
  [`recv of [`R2] role * [`M2 of unit data *
    [`close] sess]]

let role_R1 : [`R1] role = Internal.__mkrole "role_R1"
let role_R2 : [`R2] role = Internal.__mkrole "role_R2"
let role_R3 : [`R3] role = Internal.__mkrole "role_R3"

let accept_R1 : 'pre 'post. (relay,[`Implicit]) channel -> ('c, 'c, relay_R1 sess) lin_match =
  fun ch ->
  Internal.__accept ~myname:"role_R1" ~cli_count:2 ch

let connect_R2 : 'pre 'post. (relay,[`Implicit]) channel -> ('c, 'c, relay_R2 sess) lin_match =
  fun ch ->
  Internal.__connect ~myname:"role_R2" ch
let connect_R3 : 'pre 'post. (relay,[`Implicit]) channel -> ('c, 'c, relay_R3 sess) lin_match =
  fun ch ->
  Internal.__connect ~myname:"role_R3" ch

let new_channel_relay : unit -> (relay,[`Implicit]) channel = new_channel
let msg_M1 = {_pack=(fun a -> `M1(a))}
let msg_M2 = {_pack=(fun a -> `M2(a))}
