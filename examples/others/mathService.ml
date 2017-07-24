(* Generated from scribble-ocaml https://github.com/keigoi/scribble-ocaml
 * This code should be compiled with session-ocaml (multiparty)
 * https://github.com/keigoi/session-ocaml/tree/multiparty *)
open Multiparty
type mathService

type mathService_C = mathService_C_1
and mathService_C_1 = 
  [`send of
    [`Val of [`S] role * int data *
      [`send of
        [`Add of [`S] role * int data *
          [`recv of [`S] role * [`Sum of int data *
            mathService_C_1 sess]] sess
        |`Mult of [`S] role * int data *
          [`recv of [`S] role * [`Prod of int data *
            mathService_C_1 sess]] sess]] sess
    |`Bye of [`S] role * unit data *
      [`close] sess]]
type mathService_S = mathService_S_1
and mathService_S_1 = 
  [`recv of [`C] role *
    [`Val of int data *
      [`recv of [`C] role *
        [`Add of int data *
          [`send of
            [`Sum of [`C] role * int data *
              mathService_S_1 sess]] sess
        |`Mult of int data *
          [`send of
            [`Prod of [`C] role * int data *
              mathService_S_1 sess]] sess]] sess
    |`Bye of unit data *
      [`close] sess]]

let role_C : [`C] role = Internal.__mkrole "role_C"
let role_S : [`S] role = Internal.__mkrole "role_S"

let accept_C : 'pre 'post. (mathService,[`Implicit]) channel -> ('c, 'c, mathService_C sess) monad =
  fun ch ->
  Internal.__accept ~myname:"role_C" ~cli_count:1 ch

let connect_S : 'pre 'post. (mathService,[`Implicit]) channel -> ('c, 'c, mathService_S sess) monad =
  fun ch ->
  Internal.__connect ~myname:"role_S" ch

let new_channel_mathService : unit -> (mathService,[`Implicit]) channel = new_channel
let msg_Add = {_pack=(fun a -> `Add(a))}
let msg_Bye = {_pack=(fun a -> `Bye(a))}
let msg_Mult = {_pack=(fun a -> `Mult(a))}
let msg_Prod = {_pack=(fun a -> `Prod(a))}
let msg_Sum = {_pack=(fun a -> `Sum(a))}
let msg_Val = {_pack=(fun a -> `Val(a))}
