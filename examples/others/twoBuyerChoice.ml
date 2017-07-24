(* Generated from scribble-ocaml https://github.com/keigoi/scribble-ocaml
 * This code should be compiled with scribble-ocaml-runtime
 * https://github.com/keigoi/scribble-ocaml-runtime *)
open Multiparty
type twoBuyerChoice

type twoBuyerChoice_A = twoBuyerChoice_A_1
and twoBuyerChoice_A_1 = 
  [`recv of [`B] role *
    [`ok of string data *
      [`close] sess
    |`quit of unit data *
      [`close] sess]]
type twoBuyerChoice_B = twoBuyerChoice_B_1
and twoBuyerChoice_B_1 = 
  [`send of
    [`ok of [`A] role * string data *
      [`send of
        [`ok of [`S] role * string data *
          [`recv of [`S] role * [`msg of date data *
            [`close] sess]] sess]] sess
    |`quit of [`A] role * unit data *
      [`send of
        [`quit of [`S] role * unit data *
          [`close] sess]] sess]]
type twoBuyerChoice_S = twoBuyerChoice_S_1
and twoBuyerChoice_S_1 = 
  [`recv of [`B] role *
    [`ok of string data *
      [`send of
        [`msg of [`B] role * date data *
          [`close] sess]] sess
    |`quit of unit data *
      [`close] sess]]

let role_A : [`A] role = Internal.__mkrole "role_A"
let role_B : [`B] role = Internal.__mkrole "role_B"
let role_S : [`S] role = Internal.__mkrole "role_S"

let accept_B : 'pre 'post. (twoBuyerChoice,[`Implicit]) channel -> ('c, 'c, twoBuyerChoice_B sess) monad =
  fun ch ->
  Internal.__accept ~myname:"role_B" ~cli_count:2 ch

let connect_A : 'pre 'post. (twoBuyerChoice,[`Implicit]) channel -> ('c, 'c, twoBuyerChoice_A sess) monad =
  fun ch ->
  Internal.__connect ~myname:"role_A" ch
let connect_S : 'pre 'post. (twoBuyerChoice,[`Implicit]) channel -> ('c, 'c, twoBuyerChoice_S sess) monad =
  fun ch ->
  Internal.__connect ~myname:"role_S" ch

let new_channel_twoBuyerChoice : unit -> (twoBuyerChoice,[`Implicit]) channel = new_channel
let msg_none = {_pack=(fun a -> `msg(a))}
let msg_ok = {_pack=(fun a -> `ok(a))}
let msg_quit = {_pack=(fun a -> `quit(a))}
