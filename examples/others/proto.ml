(* Generated from scribble-ocaml https://github.com/keigoi/scribble-ocaml
 * This code should be compiled with session-ocaml (multiparty)
 * https://github.com/keigoi/session-ocaml/tree/multiparty *)
open Multiparty
type proto

type proto_C = proto_C_1
and proto_C_1 = 
  [`recv of [`msg of [`B] role * int *
    [`deleg_recv of [`msg of [`B] role * threebuyer.ThreeBuyer_TwoBuyerChoice_B.TwoBuyerChoice_B
      [`send of
        [`ok of [`B] role * unit *
          [`close]
        |`quit of [`B] role * unit *
          [`close]]]]]]]
type proto_B = proto_B_1
and proto_B_1 = 
  [`send of
    [`msg of [`C] role * int *
      [`send of
        [`msg of [`C] role * threebuyer.ThreeBuyer_TwoBuyerChoice_B.TwoBuyerChoice_B *
          [`recv of
            [`ok of [`C] role * unit *
              [`close]
            |`quit of [`C] role * unit *
              [`close]]]]]]]

let role_C : [`C] role = Internal.__mkrole "proto_C"
let role_B : [`B] role = Internal.__mkrole "proto_B"

let accept_B : 'pre 'post. (proto,[`ConnectFirst]) channel -> bindto:(empty, proto_B sess, 'pre, 'post) slot -> ('pre,'post,unit) monad =
  fun ch ->
  Internal.__accept ~myname:"proto_B" ~cli_count:1 ch

let connect_C : 'pre 'post. (proto,[`ConnectFirst]) channel -> bindto:(empty, proto_C sess, 'pre, 'post) slot -> ('pre,'post,unit) monad =
  fun ch ->
  Internal.__connect ~myname:"proto_C" ch

let new_channel_proto : unit -> (proto,[`ConnectLater]) channel = new_channel
let msg_none = {_pack=(fun a -> `msg(a))}
let msg_quit = {_pack=(fun a -> `quit(a))}
let msg_ok = {_pack=(fun a -> `ok(a))}
