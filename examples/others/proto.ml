(* Generated from scribble-ocaml https://github.com/keigoi/scribble-ocaml
 * This code should be compiled with session-ocaml (multiparty)
 * https://github.com/keigoi/session-ocaml/tree/multiparty *)
open Multiparty
type proto

type proto_C = proto_C_1
and proto_C_1 = 
  [`send of
    [`_1 of [`S1] role * unit data *
      [`recv of [`S1] role * [`_1a of unit data *
        [`close] sess]] sess]]
type proto_S1 = proto_S1_1
and proto_S1_1 = 
  [`recv of [`C] role * [`_1 of unit data *
    [`send of
      [`_2 of [`S2] role * unit data *
        [`recv of [`S2] role * [`_2a of unit data *
          [`send of
            [`_3 of [`S3] role * unit data *
              [`recv of [`S3] role * [`_3a of unit data *
                [`send of
                  [`_1a of [`C] role * unit data *
                    [`close] sess]] sess]] sess]] sess]] sess]] sess]]
type proto_S2 = proto_S2_1
and proto_S2_1 = 
  [`recv of [`S1] role * [`_2 of unit data *
    [`send of
      [`_2a of [`S1] role * unit data *
        [`close] sess]] sess]]
type proto_S3 = proto_S3_1
and proto_S3_1 = 
  [`recv of [`S1] role * [`_3 of unit data *
    [`send of
      [`_3a of [`S1] role * unit data *
        [`close] sess]] sess]]

let role_C : [`C] role = Internal.__mkrole "proto_C"
let role_S1 : [`S1] role = Internal.__mkrole "proto_S1"
let role_S2 : [`S2] role = Internal.__mkrole "proto_S2"
let role_S3 : [`S3] role = Internal.__mkrole "proto_S3"

let accept_C : 'pre 'post. (proto,[`ConnectFirst]) channel -> bindto:(empty, proto_C sess, 'pre, 'post) slot -> ('pre,'post,unit) monad =
  fun ch ->
  Internal.__accept ~myname:"proto_C" ~cli_count:3 ch

let connect_S1 : 'pre 'post. (proto,[`ConnectFirst]) channel -> bindto:(empty, proto_S1 sess, 'pre, 'post) slot -> ('pre,'post,unit) monad =
  fun ch ->
  Internal.__connect ~myname:"proto_S1" ch
let connect_S2 : 'pre 'post. (proto,[`ConnectFirst]) channel -> bindto:(empty, proto_S2 sess, 'pre, 'post) slot -> ('pre,'post,unit) monad =
  fun ch ->
  Internal.__connect ~myname:"proto_S2" ch
let connect_S3 : 'pre 'post. (proto,[`ConnectFirst]) channel -> bindto:(empty, proto_S3 sess, 'pre, 'post) slot -> ('pre,'post,unit) monad =
  fun ch ->
  Internal.__connect ~myname:"proto_S3" ch

let new_channel_proto : unit -> (proto,[`ConnectFirst]) channel = new_channel
let msg_1a = {_pack=(fun a -> `_1a(a))}
let msg_1 = {_pack=(fun a -> `_1(a))}
let msg_2 = {_pack=(fun a -> `_2(a))}
let msg_3 = {_pack=(fun a -> `_3(a))}
let msg_3a = {_pack=(fun a -> `_3a(a))}
let msg_2a = {_pack=(fun a -> `_2a(a))}
