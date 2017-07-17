(* Generated from scribble-ocaml https://github.com/keigoi/scribble-ocaml
 * This code should be compiled with session-ocaml (multiparty)
 * https://github.com/keigoi/session-ocaml/tree/multiparty *)
open Multiparty
type game

type game_A = game_A_1
and game_A_1 = 
  [`send of
    [`_1 of [`B] role * unit data *
      [`recv of [`C] role * [`_1 of unit data *
        game_A_1 sess]] sess
    |`_2 of [`B] role * unit data *
      [`recv of [`C] role * [`_2 of unit data *
        [`close] sess]] sess]]
type game_B = game_B_1
and game_B_1 = 
  [`recv of [`A] role *
    [`_1 of unit data *
      [`send of
        [`_1 of [`C] role * unit data *
          game_B_1 sess]] sess
    |`_2 of unit data *
      [`send of
        [`_2 of [`C] role * unit data *
          [`close] sess]] sess]]
type game_C = game_C_1
and game_C_1 = 
  [`recv of [`B] role *
    [`_1 of unit data *
      [`send of
        [`_1 of [`A] role * unit data *
          game_C_1 sess]] sess
    |`_2 of unit data *
      [`send of
        [`_2 of [`A] role * unit data *
          [`close] sess]] sess]]

let role_A : [`A] role = Internal.__mkrole "role_A"
let role_B : [`B] role = Internal.__mkrole "role_B"
let role_C : [`C] role = Internal.__mkrole "role_C"

let accept_A : 'pre 'post. (game,[`Implicit]) channel -> bindto:(empty, game_A sess, 'pre, 'post) slot -> ('pre,'post,unit) monad =
  fun ch ->
  Internal.__accept ~myname:"role_A" ~cli_count:2 ch

let connect_B : 'pre 'post. (game,[`Implicit]) channel -> bindto:(empty, game_B sess, 'pre, 'post) slot -> ('pre,'post,unit) monad =
  fun ch ->
  Internal.__connect ~myname:"role_B" ch
let connect_C : 'pre 'post. (game,[`Implicit]) channel -> bindto:(empty, game_C sess, 'pre, 'post) slot -> ('pre,'post,unit) monad =
  fun ch ->
  Internal.__connect ~myname:"role_C" ch

let new_channel_game : unit -> (game,[`Implicit]) channel = new_channel
let msg_1 = {_pack=(fun a -> `_1(a))}
let msg_2 = {_pack=(fun a -> `_2(a))}
