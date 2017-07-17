(* Generated from scribble-ocaml https://github.com/keigoi/scribble-ocaml
 * This code should be compiled with session-ocaml (multiparty)
 * https://github.com/keigoi/session-ocaml/tree/multiparty *)
open Multiparty
type rPC

type rPC_C = rPC_C_1
and rPC_C_1 = 
  [`send of
    [`M1 of [`S] role * unit data *
      [`recv of [`S] role * [`M2 of unit data *
        [`close] sess]] sess]]
type rPC_S = rPC_S_1
and rPC_S_1 = 
  [`recv of [`C] role * [`M1 of unit data *
    [`send of
      [`M2 of [`C] role * unit data *
        [`close] sess]] sess]]

let role_C : [`C] role = Internal.__mkrole "rPC_C"
let role_S : [`S] role = Internal.__mkrole "rPC_S"

let accept_C : 'pre 'post. (rPC,[`ConnectFirst]) channel -> bindto:(empty, rPC_C sess, 'pre, 'post) slot -> ('pre,'post,unit) monad =
  fun ch ->
  Internal.__accept ~myname:"rPC_C" ~cli_count:1 ch

let connect_S : 'pre 'post. (rPC,[`ConnectFirst]) channel -> bindto:(empty, rPC_S sess, 'pre, 'post) slot -> ('pre,'post,unit) monad =
  fun ch ->
  Internal.__connect ~myname:"rPC_S" ch

let new_channel_rPC : unit -> (rPC,[`ConnectFirst]) channel = new_channel
let msg_M1 = {_pack=(fun a -> `M1(a))}
let msg_M2 = {_pack=(fun a -> `M2(a))}