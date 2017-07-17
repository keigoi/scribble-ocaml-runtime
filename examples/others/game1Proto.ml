(* Generated from scribble-ocaml https://github.com/keigoi/scribble-ocaml
 * This code should be compiled with session-ocaml (multiparty)
 * https://github.com/keigoi/session-ocaml/tree/multiparty *)
open Multiparty
type game1Proto

type game1Proto_Client = game1Proto_Client_1
and game1Proto_Client_1 = 
  [`recv of [`S1] role *
    [`playAsA of unit data *
      game1Proto_Client_2 sess
    |`playAsB of game.Game1_Game_B.Game_B sess *
      [`close] sess
    |`playAsC of game.Game1_Game_C.Game_C sess *
      [`close] sess]]
and game1Proto_Client_2 = 
  [`send of
    [`_1 of [`S1] role * unit data *
      [`recv of [`S2] role * [`_1 of unit data *
        game1Proto_Client_2 sess]] sess
    |`_2 of [`S1] role * unit data *
      [`recv of [`S2] role * [`_2 of unit data *
        [`close] sess]] sess]]
type game1Proto_S1 = game1Proto_S1_1
and game1Proto_S1_1 = 
  [`send of
    [`playAsA of [`Client] role * unit data *
      game1Proto_S1_2 sess
    |`playAsB of [`Client] role * game.Game1_Game_B.Game_B sess *
      [`send of
        [`fin of [`S2] role * unit data *
          [`close] sess]] sess
    |`playAsC of [`Client] role * game.Game1_Game_C.Game_C sess *
      [`send of
        [`fin of [`S2] role * unit data *
          [`close] sess]] sess]]
and game1Proto_S1_2 = 
  [`recv of [`Client] role *
    [`_1 of unit data *
      [`send of
        [`_1 of [`S2] role * unit data *
          game1Proto_S1_2 sess]] sess
    |`_2 of unit data *
      [`send of
        [`_2 of [`S2] role * unit data *
          [`close] sess]] sess]]
type game1Proto_S2 = game1Proto_S2_1
and game1Proto_S2_1 = 
  [`recv of [`S1] role *
    [`_1 of unit data *
      [`send of
        [`_1 of [`Client] role * unit data *
          game1Proto_S2_2 sess]] sess
    |`_2 of unit data *
      [`send of
        [`_2 of [`Client] role * unit data *
          [`close] sess]] sess
    |`fin of unit data *
      [`close] sess]]
and game1Proto_S2_2 = 
  [`recv of [`S1] role *
    [`_1 of unit data *
      [`send of
        [`_1 of [`Client] role * unit data *
          game1Proto_S2_2 sess]] sess
    |`_2 of unit data *
      [`send of
        [`_2 of [`Client] role * unit data *
          [`close] sess]] sess]]

let role_Client : [`Client] role = Internal.__mkrole "game1Proto_Client"
let role_S1 : [`S1] role = Internal.__mkrole "game1Proto_S1"
let role_S2 : [`S2] role = Internal.__mkrole "game1Proto_S2"

let accept_S1 : 'pre 'post. (game1Proto,[`ConnectFirst]) channel -> bindto:(empty, game1Proto_S1 sess, 'pre, 'post) slot -> ('pre,'post,unit) monad =
  fun ch ->
  Internal.__accept ~myname:"game1Proto_S1" ~cli_count:2 ch

let connect_Client : 'pre 'post. (game1Proto,[`ConnectFirst]) channel -> bindto:(empty, game1Proto_Client sess, 'pre, 'post) slot -> ('pre,'post,unit) monad =
  fun ch ->
  Internal.__connect ~myname:"game1Proto_Client" ch
let connect_S2 : 'pre 'post. (game1Proto,[`ConnectFirst]) channel -> bindto:(empty, game1Proto_S2 sess, 'pre, 'post) slot -> ('pre,'post,unit) monad =
  fun ch ->
  Internal.__connect ~myname:"game1Proto_S2" ch

let new_channel_game1Proto : unit -> (game1Proto,[`ConnectFirst]) channel = new_channel
let msg_1 = {_pack=(fun a -> `_1(a))}
let msg_2 = {_pack=(fun a -> `_2(a))}
let msg_playAsB = {_pack=(fun a -> `playAsB(a))}
let msg_playAsC = {_pack=(fun a -> `playAsC(a))}
let msg_fin = {_pack=(fun a -> `fin(a))}
let msg_playAsA = {_pack=(fun a -> `playAsA(a))}
