type date = int
(* Generated from scribble-ocaml https://github.com/keigoi/scribble-ocaml
 * This code should be compiled with session-ocaml (multiparty)
 * https://github.com/keigoi/session-ocaml/tree/multiparty *)
open Multiparty
type twoBuyer

type twoBuyer_A = twoBuyer_A_1
and twoBuyer_A_1 = 
  [`send of
    [`msg of [`S] role * string data *
      [`recv of [`S] role * [`msg of int data *
        [`send of
          [`msg of [`B] role * int data *
            [`recv of [`B] role *
              [`ok of string data *
                [`close] sess
              |`quit of unit data *
                [`close] sess]] sess]] sess]] sess]]
type twoBuyer_B = twoBuyer_B_1
and twoBuyer_B_1 = 
  [`recv of [`S] role * [`msg of int data *
    [`recv of [`A] role * [`msg of int data *
      [`send of
        [`ok of [`A] role * string data *
          [`send of
            [`ok of [`S] role * string data *
              [`recv of [`S] role * [`msg of date data *
                [`close] sess]] sess]] sess
        |`quit of [`A] role * unit data *
          [`send of
            [`quit of [`S] role * unit data *
              [`close] sess]] sess]] sess]] sess]]
type twoBuyer_S = twoBuyer_S_1
and twoBuyer_S_1 = 
  [`recv of [`A] role * [`msg of string data *
    [`send of
      [`msg of [`A] role * int data *
        [`send of
          [`msg of [`B] role * int data *
            [`recv of [`B] role *
              [`ok of string data *
                [`send of
                  [`msg of [`B] role * date data *
                    [`close] sess]] sess
              |`quit of unit data *
                [`close] sess]] sess]] sess]] sess]]

let role_A : [`A] role = Internal.__mkrole "role_A"
let role_B : [`B] role = Internal.__mkrole "role_B"
let role_S : [`S] role = Internal.__mkrole "role_S"

let accept_A : 'pre 'post. (twoBuyer,[`Implicit]) channel -> bindto:(empty, twoBuyer_A sess, 'pre, 'post) slot -> ('pre,'post,unit) monad =
  fun ch ->
  Internal.__accept ~myname:"role_A" ~cli_count:2 ch

let connect_B : 'pre 'post. (twoBuyer,[`Implicit]) channel -> bindto:(empty, twoBuyer_B sess, 'pre, 'post) slot -> ('pre,'post,unit) monad =
  fun ch ->
  Internal.__connect ~myname:"role_B" ch
let connect_S : 'pre 'post. (twoBuyer,[`Implicit]) channel -> bindto:(empty, twoBuyer_S sess, 'pre, 'post) slot -> ('pre,'post,unit) monad =
  fun ch ->
  Internal.__connect ~myname:"role_S" ch

let new_channel_twoBuyer : unit -> (twoBuyer,[`Implicit]) channel = new_channel
let msg_none = {_pack=(fun a -> `msg(a))}
let msg_ok = {_pack=(fun a -> `ok(a))}
let msg_quit = {_pack=(fun a -> `quit(a))}
