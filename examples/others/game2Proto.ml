(* Generated from scribble-ocaml https://github.com/keigoi/scribble-ocaml
 * This code should be compiled with session-ocaml (multiparty)
 * https://github.com/keigoi/session-ocaml/tree/multiparty *)
open Multiparty
type game2Proto

type game2Proto_C = game2Proto_C_1
and game2Proto_C_1 = 
  [`recv of [`S] role *
    [`playAsA of game.Game2_Game_A.Game_A sess *
      [`close] sess
    |`playAsB of game.Game2_Game_B.Game_B sess *
      [`close] sess
    |`playAsC of game.Game2_Game_C.Game_C sess *
      [`close] sess]]
type game2Proto_S = game2Proto_S_1
and game2Proto_S_1 = 
  [`send of
    [`playAsA of [`C] role * game.Game2_Game_A.Game_A sess *
      [`close] sess
    |`playAsB of [`C] role * game.Game2_Game_B.Game_B sess *
      [`close] sess
    |`playAsC of [`C] role * game.Game2_Game_C.Game_C sess *
      [`close] sess]]

let role_C : [`C] role = Internal.__mkrole "game2Proto_C"
let role_S : [`S] role = Internal.__mkrole "game2Proto_S"

let accept_S : 'pre 'post. (game2Proto,[`ConnectFirst]) channel -> bindto:(empty, game2Proto_S sess, 'pre, 'post) slot -> ('pre,'post,unit) monad =
  fun ch ->
  Internal.__accept ~myname:"game2Proto_S" ~cli_count:1 ch

let connect_C : 'pre 'post. (game2Proto,[`ConnectFirst]) channel -> bindto:(empty, game2Proto_C sess, 'pre, 'post) slot -> ('pre,'post,unit) monad =
  fun ch ->
  Internal.__connect ~myname:"game2Proto_C" ch

let new_channel_game2Proto : unit -> (game2Proto,[`ConnectFirst]) channel = new_channel
let msg_playAsB = {_pack=(fun a -> `playAsB(a))}
let msg_playAsC = {_pack=(fun a -> `playAsC(a))}
let msg_playAsA = {_pack=(fun a -> `playAsA(a))}
