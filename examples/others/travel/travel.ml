(* Generated from scribble-ocaml https://github.com/keigoi/scribble-ocaml
 * This code should be compiled with session-ocaml (multiparty)
 * https://github.com/keigoi/session-ocaml/tree/multiparty *)
open Linocaml_lwt
open Scribble_lwt
type travel

type 'c travel_C = 'c travel_C_1
and 'c travel_C_1 = 
  [`send of
    [`Query of ([`A],'c) role * string data *
      [`recv of ([`A], 'c) role * [`Quote of int data *
        'c travel_C_1 sess]] sess
    |`Yes of ([`A], 'c) role * unit data *
      [`send of
        [`Payment of ([`S], 'c) role * string data *
          [`recv of ([`S], 'c) role * [`Ack of unit data *
            'c travel_C_2 sess]] sess]] sess
    |`No of ([`A], 'c) role * unit data *
      'c travel_C_2 sess]]
and 'c travel_C_2 = 
  [`send of
    [`Bye of ([`A], 'c) role * unit data *
      [`close] sess]]
type 'c travel_A = 'c travel_A_1
and 'c travel_A_1 = 
  [`recv of ([`C], 'c) role *
    [`Query of string data *
      [`send of
        [`Quote of ([`C], 'c) role * int data *
          [`send of
            [`Dummy of ([`S], 'c) role * unit data *
              'c travel_A_1 sess]] sess]] sess
    |`Yes of unit data *
      [`send of
        [`Yes of ([`S], 'c) role * unit data *
          'c travel_A_2 sess]] sess
    |`No of unit data *
      [`send of
        [`No of ([`S], 'c) role * unit data *
          'c travel_A_2 sess]] sess]]
and 'c travel_A_2 = 
  [`recv of ([`C], 'c) role * [`Bye of unit data *
    [`close] sess]]
type 'c travel_S = 'c travel_S_1
and 'c travel_S_1 = 
  [`recv of ([`A], 'c) role *
    [`Dummy of unit data *
      'c travel_S_1 sess
    |`Yes of unit data *
      [`recv of ([`C], 'c) role * [`Payment of string data *
        [`send of
          [`Ack of ([`C], 'c) role * unit data *
            [`close] sess]] sess]] sess
    |`No of unit data *
      [`close] sess]]

let role_C : ([`C], Endpoint.ConnKind.shmem_chan) role = Internal.__mkrole Endpoint.ConnKind.shmem_chan_kind "role_C"
let role_A : ([`A], Endpoint.ConnKind.shmem_chan) role = Internal.__mkrole Endpoint.ConnKind.shmem_chan_kind "role_A"
let role_S : ([`S], Endpoint.ConnKind.shmem_chan) role = Internal.__mkrole Endpoint.ConnKind.shmem_chan_kind "role_S"
(* let role_S : ([`S], Endpoint.ConnKind.shmem_chan) role = Internal.__mkrole ConnKind.Shmem "role_S" *)

let accept_C : 'pre 'post. travel Shmem.channel -> ('c, 'c, Endpoint.ConnKind.shmem_chan travel_C sess) monad =
  fun ch ->
  Internal.__accept ch role_C

let connect_A : 'pre 'post. travel Shmem.channel -> ('c, 'c, Endpoint.ConnKind.shmem_chan travel_A sess) monad =
  fun ch ->
  Internal.__connect ch role_A
let connect_S : 'pre 'post. travel Shmem.channel -> ('c, 'c, Endpoint.ConnKind.shmem_chan travel_S sess) monad =
  fun ch ->
  Internal.__connect ch role_S

let new_channel_travel : unit -> travel Shmem.channel = fun () -> Shmem.create_channel ["role_C";"role_A";"role_S"]
let msg_Ack = {_pack=(fun a -> `Ack(a))}
let msg_Bye = {_pack=(fun a -> `Bye(a))}
let msg_Dummy = {_pack=(fun a -> `Dummy(a))}
let msg_No = {_pack=(fun a -> `No(a))}
let msg_Payment = {_pack=(fun a -> `Payment(a))}
let msg_Query = {_pack=(fun a -> `Query(a))}
let msg_Quote = {_pack=(fun a -> `Quote(a))}
let msg_Yes = {_pack=(fun a -> `Yes(a))}
