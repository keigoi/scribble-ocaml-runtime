(* Generated from scribble-ocaml https://github.com/keigoi/scribble-ocaml
 * This code should be compiled with scribble-ocaml-runtime
 * https://github.com/keigoi/scribble-ocaml-runtime *)
open Multiparty
type game2Proto

type game2Proto_C = game2Proto_C_1
and game2Proto_C_1 = 
  [`recv of [`S] role *
    [`playAsA of Game.game_A sess *
      [`close] sess
    |`playAsB of Game.game_B sess *
      [`close] sess
    |`playAsC of Game.game_C sess *
      [`close] sess]]
type game2Proto_S = game2Proto_S_1
and game2Proto_S_1 = 
  [`send of
    [`playAsA of [`C] role * Game.game_A sess *
      [`close] sess
    |`playAsB of [`C] role * Game.game_B sess *
      [`close] sess
    |`playAsC of [`C] role * Game.game_C sess *
      [`close] sess]]

let role_C : [`C] role = Internal.__mkrole "role_C"
let role_S : [`S] role = Internal.__mkrole "role_S"

let accept_S : 'pre 'post. (game2Proto,[`Implicit]) channel -> ('c, 'c, game2Proto_S sess) monad =
  fun ch ->
  Internal.__accept ~myname:"role_S" ~cli_count:1 ch

let connect_C : 'pre 'post. (game2Proto,[`Implicit]) channel -> ('c, 'c, game2Proto_C sess) monad =
  fun ch ->
  Internal.__connect ~myname:"role_C" ch

let new_channel_game2Proto : unit -> (game2Proto,[`Implicit]) channel = new_channel
let msg_playAsA = {_pack=(fun a -> `playAsA(a))}
let msg_playAsB = {_pack=(fun a -> `playAsB(a))}
let msg_playAsC = {_pack=(fun a -> `playAsC(a))}
