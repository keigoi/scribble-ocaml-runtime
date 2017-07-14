(* Generated from scribble-ocaml https://github.com/keigoi/scribble-ocaml
 * This code should be compiled with session-ocaml (multiparty)
 * https://github.com/keigoi/session-ocaml/tree/multiparty *)
open Multiparty
type rPCComp

type rPCComp_C = rPCComp_C_1
and rPCComp_C_1 = 
  [`send of
    [`_1 of [`S1] role * unit *
      [`recv of [`_1a of [`S1] role * unit *
        [`close]]]]]
type rPCComp_S1 = rPCComp_S1_1
and rPCComp_S1_1 = 
  [`recv of [`_1 of [`C] role * unit *
    [`send of
      [`_2 of [`S2] role * unit *
        [`recv of [`_2a of [`S2] role * unit *
          [`send of
            [`_3 of [`S3] role * unit *
              [`recv of [`_3a of [`S3] role * unit *
                [`send of
                  [`_1a of [`C] role * unit *
                    [`close]]]]]]]]]]]]]
type rPCComp_S2 = rPCComp_S2_1
and rPCComp_S2_1 = 
  [`recv of [`_2 of [`S1] role * unit *
    [`send of
      [`_2a of [`S1] role * unit *
        [`close]]]]]
type rPCComp_S3 = rPCComp_S3_1
and rPCComp_S3_1 = 
  [`recv of [`_3 of [`S1] role * unit *
    [`send of
      [`_3a of [`S1] role * unit *
        [`close]]]]]

let role_C : [`C] role = Internal.__mkrole "rPCComp_C"
let role_S1 : [`S1] role = Internal.__mkrole "rPCComp_S1"
let role_S2 : [`S2] role = Internal.__mkrole "rPCComp_S2"
let role_S3 : [`S3] role = Internal.__mkrole "rPCComp_S3"

let accept_C : 'pre 'post. (rPCComp,[`ConnectFirst]) channel -> bindto:(empty, rPCComp_C sess, 'pre, 'post) slot -> ('pre,'post,unit) monad =
  fun ch ->
  Internal.__accept ~myname:"rPCComp_C" ~cli_count:3 ch

let connect_S1 : 'pre 'post. (rPCComp,[`ConnectFirst]) channel -> bindto:(empty, rPCComp_S1 sess, 'pre, 'post) slot -> ('pre,'post,unit) monad =
  fun ch ->
  Internal.__connect ~myname:"rPCComp_S1" ch
let connect_S2 : 'pre 'post. (rPCComp,[`ConnectFirst]) channel -> bindto:(empty, rPCComp_S2 sess, 'pre, 'post) slot -> ('pre,'post,unit) monad =
  fun ch ->
  Internal.__connect ~myname:"rPCComp_S2" ch
let connect_S3 : 'pre 'post. (rPCComp,[`ConnectFirst]) channel -> bindto:(empty, rPCComp_S3 sess, 'pre, 'post) slot -> ('pre,'post,unit) monad =
  fun ch ->
  Internal.__connect ~myname:"rPCComp_S3" ch

let new_channel_rPCComp : unit -> (rPCComp,[`ConnectFirst]) channel = new_channel
let msg_1a = {_pack=(fun a -> `_1a(a))}
let msg_1 = {_pack=(fun a -> `_1(a))}
let msg_2 = {_pack=(fun a -> `_2(a))}
let msg_3 = {_pack=(fun a -> `_3(a))}
let msg_3a = {_pack=(fun a -> `_3a(a))}
let msg_2a = {_pack=(fun a -> `_2a(a))}
