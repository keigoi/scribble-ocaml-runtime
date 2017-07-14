(* Generated from scribble-ocaml https://github.com/keigoi/scribble-ocaml
 * This code should be compiled with session-ocaml (multiparty)
 * https://github.com/keigoi/session-ocaml/tree/multiparty *)
open Multiparty
type twoBuyer

type twoBuyer_A = twoBuyer_A_1
and twoBuyer_A_1 = 
  [`send of
    [`msg of [`S] role * string *
      [`recv of [`msg of [`S] role * int *
        [`send of
          [`msg of [`B] role * int *
            [`recv of
              [`ok of [`B] role * string *
                [`close]
              |`quit of [`B] role * unit *
                [`close]]]]]]]]]
type twoBuyer_B = twoBuyer_B_1
and twoBuyer_B_1 = 
  [`recv of [`msg of [`S] role * int *
    [`recv of [`msg of [`A] role * int *
      [`send of
        [`ok of [`A] role * string *
          [`send of
            [`ok of [`S] role * string *
              [`recv of [`msg of [`S] role * date *
                [`close]]]]]
        |`quit of [`A] role * unit *
          [`send of
            [`quit of [`S] role * unit *
              [`close]]]]]]]]]
type twoBuyer_S = twoBuyer_S_1
and twoBuyer_S_1 = 
  [`recv of [`msg of [`A] role * string *
    [`send of
      [`msg of [`A] role * int *
        [`send of
          [`msg of [`B] role * int *
            [`recv of
              [`ok of [`B] role * string *
                [`send of
                  [`msg of [`B] role * date *
                    [`close]]]
              |`quit of [`B] role * unit *
                [`close]]]]]]]]]

let role_A : [`A] role = Internal.__mkrole "twoBuyer_A"
let role_B : [`B] role = Internal.__mkrole "twoBuyer_B"
let role_S : [`S] role = Internal.__mkrole "twoBuyer_S"

let accept_A : 'pre 'post. (twoBuyer,[`ConnectFirst]) channel -> bindto:(empty, twoBuyer_A sess, 'pre, 'post) slot -> ('pre,'post,unit) monad =
  fun ch ->
  Internal.__accept ~myname:"twoBuyer_A" ~cli_count:2 ch

let connect_B : 'pre 'post. (twoBuyer,[`ConnectFirst]) channel -> bindto:(empty, twoBuyer_B sess, 'pre, 'post) slot -> ('pre,'post,unit) monad =
  fun ch ->
  Internal.__connect ~myname:"twoBuyer_B" ch
let connect_S : 'pre 'post. (twoBuyer,[`ConnectFirst]) channel -> bindto:(empty, twoBuyer_S sess, 'pre, 'post) slot -> ('pre,'post,unit) monad =
  fun ch ->
  Internal.__connect ~myname:"twoBuyer_S" ch

let new_channel_twoBuyer : unit -> (twoBuyer,[`ConnectLater]) channel = new_channel
let msg_none = {_pack=(fun a -> `msg(a))}
let msg_quit = {_pack=(fun a -> `quit(a))}
let msg_ok = {_pack=(fun a -> `ok(a))}
