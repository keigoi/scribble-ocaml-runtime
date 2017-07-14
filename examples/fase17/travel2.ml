(* Generated from scribble-ocaml https://github.com/keigoi/scribble-ocaml
 * This code should be compiled with session-ocaml (multiparty)
 * https://github.com/keigoi/session-ocaml/tree/multiparty *)
open Multiparty
type travel

type travel_C = travel_C_1
and travel_C_1 = 
  [`connect of
    [`msg of [`A] role * unit *
      travel_C_2]]
and travel_C_2 = 
  [`send of
    [`query of [`A] role * str *
      [`recv of [`quote of [`A] role * int *
        travel_C_2]]
    |`accpt of [`A] role * unit *
      [`recv of [`port of [`A] role * int *
        [`connect of
          [`msg of [`S] role * unit *
            [`send of
              [`pay of [`S] role * str *
                [`recv of [`confirm of [`S] role * int *
                  [`send of
                    [`ack of [`A] role * int *
                      [`close]]]]]]]]]]]
    |`reject of [`A] role * unit *
      [`close]]]
type travel_A = travel_A_1
and travel_A_1 = 
  [`accept of
    [`msg of [`C] role * unit *
      travel_A_2]]
and travel_A_2 = 
  [`recv of
    [`query of [`C] role * str *
      [`send of
        [`quote of [`C] role * int *
          travel_A_2]]
    |`accpt of [`C] role * unit *
      [`connect of
        [`msg of [`S] role * unit *
          [`recv of [`port of [`S] role * int *
            [`send of
              [`port of [`C] role * int *
                [`recv of [`ack of [`C] role * int *
                  [`close]]]]]]]]]
    |`reject of [`C] role * unit *
      [`close]]]
type travel_S = travel_S_1
and travel_S_1 = 
  [`accept of
    [`msg of [`A] role * unit *
      [`send of
        [`port of [`A] role * int *
          [`accept of
            [`msg of [`C] role * unit *
              [`recv of [`pay of [`C] role * str *
                [`send of
                  [`confirm of [`C] role * int *
                    [`close]]]]]]]]]]]

let role_C : [`C] role = Internal.__mkrole "travel_C"
let role_A : [`A] role = Internal.__mkrole "travel_A"
let role_S : [`S] role = Internal.__mkrole "travel_S"

let initiate_C : 'pre 'post. (travel,[`ConnectLater]) channel -> bindto:(empty, travel_C sess, 'pre, 'post) slot -> ('pre,'post,unit) monad =
  fun ch ->
  Internal.__initiate ~myname:"travel_C" ch
let initiate_A : 'pre 'post. (travel,[`ConnectLater]) channel -> bindto:(empty, travel_A sess, 'pre, 'post) slot -> ('pre,'post,unit) monad =
  fun ch ->
  Internal.__initiate ~myname:"travel_A" ch
let initiate_S : 'pre 'post. (travel,[`ConnectLater]) channel -> bindto:(empty, travel_S sess, 'pre, 'post) slot -> ('pre,'post,unit) monad =
  fun ch ->
  Internal.__initiate ~myname:"travel_S" ch

let new_channel_travel () : (travel,[`ConnectLater]) channel = Internal.__new_connect_later_channel ["travel_C";"travel_A";"travel_S"]
let msg_none = {_pack=(fun a -> `msg(a))}
let msg_accpt = {_pack=(fun a -> `accpt(a))}
let msg_confirm = {_pack=(fun a -> `confirm(a))}
let msg_quote = {_pack=(fun a -> `quote(a))}
let msg_port = {_pack=(fun a -> `port(a))}
let msg_reject = {_pack=(fun a -> `reject(a))}
let msg_query = {_pack=(fun a -> `query(a))}
let msg_ack = {_pack=(fun a -> `ack(a))}
let msg_pay = {_pack=(fun a -> `pay(a))}
