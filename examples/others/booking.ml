(* Generated from scribble-ocaml https://github.com/keigoi/scribble-ocaml
 * This code should be compiled with session-ocaml (multiparty)
 * https://github.com/keigoi/session-ocaml/tree/multiparty *)
open Multiparty
type booking

type booking_C = booking_C_1
and booking_C_1 = 
  [`send of
    [`Query of [`A] role * string data *
      [`recv of [`A] role * [`Quote of int data *
        booking_C_1 sess]] sess
    |`Yes of [`A] role * unit data *
      [`send of
        [`Payment of [`S] role * string data *
          [`recv of [`S] role * [`Ack of unit data *
            booking_C_2 sess]] sess]] sess
    |`No of [`A] role * unit data *
      booking_C_2 sess]]
and booking_C_2 = 
  [`send of
    [`Bye of [`A] role * unit data *
      [`close] sess]]
type booking_A = booking_A_1
and booking_A_1 = 
  [`recv of [`C] role *
    [`Query of string data *
      [`send of
        [`Quote of [`C] role * int data *
          [`send of
            [`Dummy of [`S] role * unit data *
              booking_A_1 sess]] sess]] sess
    |`Yes of unit data *
      [`send of
        [`Yes of [`S] role * unit data *
          booking_A_2 sess]] sess
    |`No of unit data *
      [`send of
        [`No of [`S] role * unit data *
          booking_A_2 sess]] sess]]
and booking_A_2 = 
  [`recv of [`C] role * [`Bye of unit data *
    [`close] sess]]
type booking_S = booking_S_1
and booking_S_1 = 
  [`recv of [`A] role *
    [`Dummy of unit data *
      booking_S_1 sess
    |`Yes of unit data *
      [`recv of [`C] role * [`Payment of string data *
        [`send of
          [`Ack of [`C] role * unit data *
            [`close] sess]] sess]] sess
    |`No of unit data *
      [`close] sess]]

let role_C : [`C] role = Internal.__mkrole "role_C"
let role_A : [`A] role = Internal.__mkrole "role_A"
let role_S : [`S] role = Internal.__mkrole "role_S"

let accept_C : 'pre 'post. (booking,[`Implicit]) channel -> bindto:(empty, booking_C sess, 'pre, 'post) slot -> ('pre,'post,unit) monad =
  fun ch ->
  Internal.__accept ~myname:"role_C" ~cli_count:2 ch

let connect_A : 'pre 'post. (booking,[`Implicit]) channel -> bindto:(empty, booking_A sess, 'pre, 'post) slot -> ('pre,'post,unit) monad =
  fun ch ->
  Internal.__connect ~myname:"role_A" ch
let connect_S : 'pre 'post. (booking,[`Implicit]) channel -> bindto:(empty, booking_S sess, 'pre, 'post) slot -> ('pre,'post,unit) monad =
  fun ch ->
  Internal.__connect ~myname:"role_S" ch

let new_channel_booking : unit -> (booking,[`Implicit]) channel = new_channel
let msg_Ack = {_pack=(fun a -> `Ack(a))}
let msg_Bye = {_pack=(fun a -> `Bye(a))}
let msg_Dummy = {_pack=(fun a -> `Dummy(a))}
let msg_No = {_pack=(fun a -> `No(a))}
let msg_Payment = {_pack=(fun a -> `Payment(a))}
let msg_Query = {_pack=(fun a -> `Query(a))}
let msg_Quote = {_pack=(fun a -> `Quote(a))}
let msg_Yes = {_pack=(fun a -> `Yes(a))}
