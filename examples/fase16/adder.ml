(* Generated from scribble-ocaml https://github.com/keigoi/scribble-ocaml
 * This code should be compiled with session-ocaml (multiparty)
 * https://github.com/keigoi/session-ocaml/tree/multiparty *)
open Multiparty
type adder

type integer = int

type adder_C = adder_C_1
and adder_C_1 = 
  [`send of
    [`Add of [`S] role * (integer * integer) *
      [`recv of [`Res of [`S] role * integer *
        adder_C_1]]
    |`Bye of [`S] role * unit *
      [`recv of [`Bye of [`S] role * unit *
        [`close]]]]]
type adder_S = adder_S_1
and adder_S_1 = 
  [`recv of
    [`Add of [`C] role * (integer*integer) *
      [`send of
        [`Res of [`C] role * integer *
          adder_S_1]]
    |`Bye of [`C] role * unit *
      [`send of
        [`Bye of [`C] role * unit *
          [`close]]]]]

let role_C : [`C] role = Internal.__mkrole "adder_C"
let role_S : [`S] role = Internal.__mkrole "adder_S"

let accept_C : 'pre 'post. (adder,[`ConnectFirst]) channel -> bindto:(empty, adder_C sess, 'pre, 'post) slot -> ('pre,'post,unit) monad =
  fun ch ->
  Internal.__accept ~myname:"adder_C" ~cli_count:1 ch

let connect_S : 'pre 'post. (adder,[`ConnectFirst]) channel -> bindto:(empty, adder_S sess, 'pre, 'post) slot -> ('pre,'post,unit) monad =
  fun ch ->
  Internal.__connect ~myname:"adder_S" ch

let new_channel_adder : unit -> (adder,[`ConnectFirst]) channel = new_channel
let msg_Add = {_pack=(fun a -> `Add(a))}
let msg_Res = {_pack=(fun a -> `Res(a))}
let msg_Bye = {_pack=(fun a -> `Bye(a))}
