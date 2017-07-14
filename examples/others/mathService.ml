(* Generated from scribble-ocaml https://github.com/keigoi/scribble-ocaml
 * This code should be compiled with session-ocaml (multiparty)
 * https://github.com/keigoi/session-ocaml/tree/multiparty *)
open Multiparty
type mathService

type mathService_C = mathService_C_1
and mathService_C_1 = 
  [`send of
    [`Val of [`S] role * int *
      [`send of
        [`Add of [`S] role * int *
          [`recv of [`Sum of [`S] role * int *
            mathService_C_1]]
        |`Mult of [`S] role * int *
          [`recv of [`Prod of [`S] role * int *
            mathService_C_1]]]]
    |`Bye of [`S] role * unit *
      [`close]]]
type mathService_S = mathService_S_1
and mathService_S_1 = 
  [`recv of
    [`Val of [`C] role * int *
      [`recv of
        [`Add of [`C] role * int *
          [`send of
            [`Sum of [`C] role * int *
              mathService_S_1]]
        |`Mult of [`C] role * int *
          [`send of
            [`Prod of [`C] role * int *
              mathService_S_1]]]]
    |`Bye of [`C] role * unit *
      [`close]]]

let role_C : [`C] role = Internal.__mkrole "mathService_C"
let role_S : [`S] role = Internal.__mkrole "mathService_S"

let accept_C : 'pre 'post. (mathService,[`ConnectFirst]) channel -> bindto:(empty, mathService_C sess, 'pre, 'post) slot -> ('pre,'post,unit) monad =
  fun ch ->
  Internal.__accept ~myname:"mathService_C" ~cli_count:1 ch

let connect_S : 'pre 'post. (mathService,[`ConnectFirst]) channel -> bindto:(empty, mathService_S sess, 'pre, 'post) slot -> ('pre,'post,unit) monad =
  fun ch ->
  Internal.__connect ~myname:"mathService_S" ch

let new_channel_mathService : unit -> (mathService,[`ConnectFirst]) channel = new_channel
let msg_Val = {_pack=(fun a -> `Val(a))}
let msg_Add = {_pack=(fun a -> `Add(a))}
let msg_Prod = {_pack=(fun a -> `Prod(a))}
let msg_Mult = {_pack=(fun a -> `Mult(a))}
let msg_Sum = {_pack=(fun a -> `Sum(a))}
let msg_Bye = {_pack=(fun a -> `Bye(a))}
