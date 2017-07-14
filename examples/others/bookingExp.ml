(* Generated from scribble-ocaml https://github.com/keigoi/scribble-ocaml
 * This code should be compiled with session-ocaml (multiparty)
 * https://github.com/keigoi/session-ocaml/tree/multiparty *)
open Multiparty
type bookingExp

type bookingExp_C = bookingExp_C_1
and bookingExp_C_1 = 
  [`send of
    [`msg of [`A] role connect * unit *
      bookingExp_C_2]]
and bookingExp_C_2 = 
  [`send of
    [`Query of [`A] role * string *
      [`recv of [`Quote of [`A] role * int *
        bookingExp_C_2]]
    |`Yes of [`A] role * unit *
      [`accept of
        [`msg of [`S] role * unit *
          [`send of
            [`Payment of [`S] role * string *
              [`recv of [`Ack of [`S] role * unit *
                bookingExp_C_3]]]]]]
    |`No of [`A] role * unit *
      bookingExp_C_3]]
and bookingExp_C_3 = 
  [`send of
    [`Bye of [`A] role * unit *
      [`close]]]
type bookingExp_A = bookingExp_A_1
and bookingExp_A_1 = 
  [`accept of
    [`msg of [`C] role * unit *
      bookingExp_A_2]]
and bookingExp_A_2 = 
  [`recv of
    [`Query of [`C] role * string *
      [`send of
        [`Quote of [`C] role * int *
          bookingExp_A_2]]
    |`Yes of [`C] role * unit *
      [`send of
        [`msg of [`S] role connect * unit *
          [`send of
            [`Yes of [`S] role * unit *
              bookingExp_A_3]]]]
    |`No of [`C] role * unit *
      bookingExp_A_3]]
and bookingExp_A_3 = 
  [`recv of [`Bye of [`C] role * unit *
    [`close]]]
type bookingExp_S = bookingExp_S_1
and bookingExp_S_1 = 
  [`accept of
    [`msg of [`A] role * unit *
      [`recv of [`Yes of [`A] role * unit *
        [`send of
          [`msg of [`C] role connect * unit *
            [`recv of [`Payment of [`C] role * string *
              [`send of
                [`Ack of [`C] role * unit *
                  [`close]]]]]]]]]]]

let role_C : [`C] role = Internal.__mkrole "bookingExp_C"
let role_A : [`A] role = Internal.__mkrole "bookingExp_A"
let role_S : [`S] role = Internal.__mkrole "bookingExp_S"

let initiate_C : 'pre 'post. (bookingExp,[`ConnectLater]) channel -> bindto:(empty, bookingExp_C sess, 'pre, 'post) slot -> ('pre,'post,unit) monad =
  fun ch ->
  Internal.__initiate ~myname:"bookingExp_C" ch
let initiate_A : 'pre 'post. (bookingExp,[`ConnectLater]) channel -> bindto:(empty, bookingExp_A sess, 'pre, 'post) slot -> ('pre,'post,unit) monad =
  fun ch ->
  Internal.__initiate ~myname:"bookingExp_A" ch
let initiate_S : 'pre 'post. (bookingExp,[`ConnectLater]) channel -> bindto:(empty, bookingExp_S sess, 'pre, 'post) slot -> ('pre,'post,unit) monad =
  fun ch ->
  Internal.__initiate ~myname:"bookingExp_S" ch

let new_channel_bookingExp () : (bookingExp,[`ConnectLater]) channel = Internal.__new_connect_later_channel ["bookingExp_C";"bookingExp_A";"bookingExp_S"]
let msg_none = {_pack=(fun a -> `msg(a))}
let msg_Quote = {_pack=(fun a -> `Quote(a))}
let msg_No = {_pack=(fun a -> `No(a))}
let msg_Payment = {_pack=(fun a -> `Payment(a))}
let msg_Query = {_pack=(fun a -> `Query(a))}
let msg_Yes = {_pack=(fun a -> `Yes(a))}
let msg_Ack = {_pack=(fun a -> `Ack(a))}
let msg_Bye = {_pack=(fun a -> `Bye(a))}
