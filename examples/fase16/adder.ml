(* Generated from scribble-ocaml https://github.com/keigoi/scribble-ocaml
 * This code should be compiled with session-ocaml (multiparty)
 * https://github.com/keigoi/session-ocaml/tree/multiparty *)
open Multiparty
type adder

type adder_C = adder_C_1
and adder_C_1 = 
  [`send of
    [`Add of [`S] role * (int * int) data *
      [`recv of [`S] role * [`Res of int data *
        adder_C_1 sess]] sess
    |`Bye of [`S] role * unit data *
      [`recv of [`S] role * [`Bye of unit data *
        [`close] sess]] sess]]
type adder_S = adder_S_1
and adder_S_1 = 
  [`recv of [`C] role *
    [`Add of (int * int) data *
      [`send of
        [`Res of [`C] role * int data *
          adder_S_1 sess]] sess
    |`Bye of unit data *
      [`send of
        [`Bye of [`C] role * unit data *
          [`close] sess]] sess]]

let role_C : [`C] role = Internal.__mkrole "role_C"
let role_S : [`S] role = Internal.__mkrole "role_S"

let accept_C : 'pre 'post. (adder,[`Implicit]) channel -> ('c, 'c, adder_C sess) monad =
  fun ch ->
  Internal.__accept ~myname:"role_C" ~cli_count:1 ch

let connect_S : 'pre 'post. (adder,[`Implicit]) channel -> ('c, 'c, adder_S sess) monad =
  fun ch ->
  Internal.__connect ~myname:"role_S" ch

let new_channel_adder : unit -> (adder,[`Implicit]) channel = new_channel
let msg_Add = {_pack=(fun a -> `Add(a))}
let msg_Bye = {_pack=(fun a -> `Bye(a))}
let msg_Res = {_pack=(fun a -> `Res(a))}
