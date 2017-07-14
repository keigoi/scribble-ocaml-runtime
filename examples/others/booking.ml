(* Generated from scribble-ocaml https://github.com/keigoi/scribble-ocaml
 * This code should be compiled with session-ocaml (multiparty)
 * https://github.com/keigoi/session-ocaml/tree/multiparty *)
open Multiparty
type booking

type booking_C = booking_C_1
and booking_C_1 = 
  [`send of
    [`Query of [`A] role * string *
      [`recv of [`Quote of [`A] role * int *
        booking_C_1]]
    |`Yes of [`A] role * unit *
      [`send of
        [`Payment of [`S] role * string *
          [`recv of [`Ack of [`S] role * unit *
            booking_C_2]]]]
    |`No of [`A] role * unit *
      booking_C_2]]
and booking_C_2 = 
  [`send of
    [`Bye of [`A] role * unit *
      [`close]]]
type booking_A = booking_A_1
and booking_A_1 = 
  [`recv of
    [`Query of [`C] role * string *
      [`send of
        [`Quote of [`C] role * int *
          [`send of
            [`Dummy of [`S] role * unit *
              booking_A_1]]]]
    |`Yes of [`C] role * unit *
      [`send of
        [`Yes of [`S] role * unit *
          booking_A_2]]
    |`No of [`C] role * unit *
      [`send of
        [`No of [`S] role * unit *
          booking_A_2]]]]
and booking_A_2 = 
  [`recv of [`Bye of [`C] role * unit *
    [`close]]]
type booking_S = booking_S_1
and booking_S_1 = 
  [`recv of
    [`Dummy of [`A] role * unit *
      booking_S_1
    |`Yes of [`A] role * unit *
      [`recv of [`Payment of [`C] role * string *
        [`send of
          [`Ack of [`C] role * unit *
            [`close]]]]]
    |`No of [`A] role * unit *
      [`close]]]

let role_C : [`C] role = Internal.__mkrole "booking_C"
let role_A : [`A] role = Internal.__mkrole "booking_A"
let role_S : [`S] role = Internal.__mkrole "booking_S"

let accept_C : 'pre 'post. (booking,[`ConnectFirst]) channel -> bindto:(empty, booking_C sess, 'pre, 'post) slot -> ('pre,'post,unit) monad =
  fun ch ->
  Internal.__accept ~myname:"booking_C" ~cli_count:2 ch

let connect_A : 'pre 'post. (booking,[`ConnectFirst]) channel -> bindto:(empty, booking_A sess, 'pre, 'post) slot -> ('pre,'post,unit) monad =
  fun ch ->
  Internal.__connect ~myname:"booking_A" ch
let connect_S : 'pre 'post. (booking,[`ConnectFirst]) channel -> bindto:(empty, booking_S sess, 'pre, 'post) slot -> ('pre,'post,unit) monad =
  fun ch ->
  Internal.__connect ~myname:"booking_S" ch

let new_channel_booking : unit -> (booking,[`ConnectFirst]) channel = new_channel
let msg_Quote = {_pack=(fun a -> `Quote(a))}
let msg_No = {_pack=(fun a -> `No(a))}
let msg_Payment = {_pack=(fun a -> `Payment(a))}
let msg_Query = {_pack=(fun a -> `Query(a))}
let msg_Yes = {_pack=(fun a -> `Yes(a))}
let msg_Ack = {_pack=(fun a -> `Ack(a))}
let msg_Dummy = {_pack=(fun a -> `Dummy(a))}
let msg_Bye = {_pack=(fun a -> `Bye(a))}
