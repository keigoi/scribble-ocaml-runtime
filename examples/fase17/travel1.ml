(* Generated from scribble-ocaml https://github.com/keigoi/scribble-ocaml
 * This code should be compiled with scribble-ocaml-runtime
 * https://github.com/keigoi/scribble-ocaml-runtime *)
open Scribble.Direct (* or: open Scribble_lwt *)
type travel1

type ('c_A, 'c_S) travel1_C = ('c_A, 'c_S) travel1_C_1
and ('c_A, 'c_S) travel1_C_1 =
  [`send of
    [`msg of ([`A], 'c_A) role connect * unit data *
      ('c_A, 'c_S) travel1_C_2 sess]]
and ('c_A, 'c_S) travel1_C_2 =
  [`send of
    [`query of ([`A], 'c_A) role * string data *
      [`recv of ([`A], 'c_A) role * [`quote of int data *
        ('c_A, 'c_S) travel1_C_2 sess]] sess
    |`msg of ([`S], 'c_S) role connect * unit data *
      [`send of
        [`pay of ([`S], 'c_S) role * string data *
          [`recv of ([`S], 'c_S) role * [`confirm of int data *
            [`send of
              [`accpt of ([`A], 'c_A) role * int data *
                [`close] sess]] sess]] sess]] sess
    |`reject of ([`A], 'c_A) role * unit data *
      [`close] sess]]
type ('c_C, 'c_S) travel1_A = ('c_C, 'c_S) travel1_A_1
and ('c_C, 'c_S) travel1_A_1 =
  [`accept of ([`C], 'c_C) role *
    [`msg of unit data *
      ('c_C, 'c_S) travel1_A_2 sess]]
and ('c_C, 'c_S) travel1_A_2 =
  [`recv of ([`C], 'c_C) role *
    [`query of string data *
      [`send of
        [`quote of ([`C], 'c_C) role * int data *
          ('c_C, 'c_S) travel1_A_2 sess]] sess
    |`accpt of int data *
      [`close] sess
    |`reject of unit data *
      [`close] sess]]
type ('c_C, 'c_A) travel1_S = ('c_C, 'c_A) travel1_S_1
and ('c_C, 'c_A) travel1_S_1 =
  [`accept of ([`C], 'c_C) role *
    [`msg of unit data *
      [`recv of ([`C], 'c_C) role * [`pay of string data *
        [`send of
          [`confirm of ([`C], 'c_C) role * int data *
            [`close] sess]] sess]] sess]]

let mk_role_C c : ([`C], _) role = Internal.__mkrole c "role_C"
let mk_role_A c : ([`A], _) role = Internal.__mkrole c "role_A"
let mk_role_S c : ([`S], _) role = Internal.__mkrole c "role_S"

let initiate_C : unit -> ('c, 'c, ('c_A, 'c_S) travel1_C sess) monad =
  fun () ->
  Internal.__initiate ~myname:"role_C"
let initiate_A : unit -> ('c, 'c, ('c_C, 'c_S) travel1_A sess) monad =
  fun () ->
  Internal.__initiate ~myname:"role_A"
let initiate_S : unit -> ('c, 'c, ('c_C, 'c_A) travel1_S sess) monad =
  fun () ->
  Internal.__initiate ~myname:"role_S"

let msg_none = {_pack=(fun a -> `msg(a))}
let msg_accpt = {_pack=(fun a -> `accpt(a))}
let msg_confirm = {_pack=(fun a -> `confirm(a))}
let msg_pay = {_pack=(fun a -> `pay(a))}
let msg_query = {_pack=(fun a -> `query(a))}
let msg_quote = {_pack=(fun a -> `quote(a))}
let msg_reject = {_pack=(fun a -> `reject(a))}
