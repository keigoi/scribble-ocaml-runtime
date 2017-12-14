(* Generated from scribble-ocaml https://github.com/keigoi/scribble-ocaml
 * This code should be compiled with scribble-ocaml-runtime
 * https://github.com/keigoi/scribble-ocaml-runtime *)
open Scribble_lwt
type oAuth

type uRL = string and form and scope and id and pass and code and accessToken

type ('c_C, 'c_A) oAuth_U = ('c_C, 'c_A) oAuth_U_1
and ('c_C, 'c_A) oAuth_U_1 =
  [`send of
    [`oauth of ([`C], 'c_C) role connect * unit data *
      [`recv of ([`C], 'c_C) role * [`_302 of (uRL * uRL) data *
        [`disconnect of ([`C], 'c_C) role *
          [`send of
            [`authorize_request of ([`A], 'c_A) role connect * uRL data *
              [`recv of ([`A], 'c_A) role * [`_200 of (form * scope) data *
                [`disconnect of ([`A], 'c_A) role *
                  [`send of
                    [`submit of ([`A], 'c_A) role connect * (id * pass) data *
                      [`recv of ([`A], 'c_A) role *
                        [`_400 of unit data *
                          [`disconnect of ([`A], 'c_A) role *
                            [`send of
                              [`login_fail of ([`C], 'c_C) role connect * uRL data *
                                [`recv of ([`C], 'c_C) role * [`_200 of unit data *
                                  [`close] sess]] sess]] sess] sess
                        |`_302 of code data *
                          [`disconnect of ([`A], 'c_A) role *
                            [`send of
                              [`success of ([`C], 'c_C) role connect * (uRL * code) data *
                                [`recv of ([`C], 'c_C) role * [`_200 of unit data *
                                  [`disconnect of ([`C], 'c_C) role *
                                    [`close] sess] sess]] sess]] sess] sess]] sess]] sess] sess]] sess]] sess] sess]] sess]]
type ('c_U, 'c_A) oAuth_C = ('c_U, 'c_A) oAuth_C_1
and ('c_U, 'c_A) oAuth_C_1 =
  [`accept of ([`U], 'c_U) role *
    [`oauth of unit data *
      [`send of
        [`_302 of ([`U], 'c_U) role * (uRL * uRL) data *
          [`disconnect of ([`U], 'c_U) role *
            [`accept of ([`U], 'c_U) role *
              [`login_fail of uRL data *
                [`send of
                  [`_200 of ([`U], 'c_U) role * unit data *
                    [`close] sess]] sess
              |`success of (uRL * code) data *
                [`send of
                  [`tokens of ([`A], 'c_A) role connect * code data *
                    [`recv of ([`A], 'c_A) role * [`_200 of accessToken data *
                      [`disconnect of ([`A], 'c_A) role *
                        [`send of
                          [`_200 of ([`U], 'c_U) role * unit data *
                            [`disconnect of ([`U], 'c_U) role *
                              [`close] sess] sess]] sess] sess]] sess]] sess]] sess] sess]] sess]]
type ('c_U, 'c_C) oAuth_A = ('c_U, 'c_C) oAuth_A_1
and ('c_U, 'c_C) oAuth_A_1 =
  [`accept of ([`U], 'c_U) role *
    [`authorize_request of uRL data *
      [`send of
        [`_200 of ([`U], 'c_U) role * (form * scope) data *
          [`disconnect of ([`U], 'c_U) role *
            [`accept of ([`U], 'c_U) role *
              [`submit of (id * pass) data *
                [`send of
                  [`_400 of ([`U], 'c_U) role * unit data *
                    [`disconnect of ([`U], 'c_U) role *
                      [`close] sess] sess
                  |`_302 of ([`U], 'c_U) role * code data *
                    [`disconnect of ([`U], 'c_U) role *
                      [`accept of ([`C], 'c_C) role *
                        [`tokens of code data *
                          [`send of
                            [`_200 of ([`C], 'c_C) role * accessToken data *
                              [`disconnect of ([`C], 'c_C) role *
                                [`close] sess] sess]] sess]] sess] sess]] sess]] sess] sess]] sess]]

let mk_role_U c : ([`U], _) role = Internal.__mkrole c "role_U"
let mk_role_C c : ([`C], _) role = Internal.__mkrole c "role_C"
let mk_role_A c : ([`A], _) role = Internal.__mkrole c "role_A"

let initiate_U : unit -> ('c, 'c, ('c_C, 'c_A) oAuth_U sess) monad =
  fun () ->
  Internal.__initiate ~myname:"role_U"
let initiate_C : unit -> ('c, 'c, ('c_U, 'c_A) oAuth_C sess) monad =
  fun () ->
  Internal.__initiate ~myname:"role_C"
let initiate_A : unit -> ('c, 'c, ('c_U, 'c_C) oAuth_A sess) monad =
  fun () ->
  Internal.__initiate ~myname:"role_A"

let msg_none = {_pack=(fun a -> `msg(a))}
let msg_200 = {_pack=(fun a -> `_200(a))}
let msg_302 = {_pack=(fun a -> `_302(a))}
let msg_400 = {_pack=(fun a -> `_400(a))}
let msg_authorize_request = {_pack=(fun a -> `authorize_request(a))}
let msg_login_fail = {_pack=(fun a -> `login_fail(a))}
let msg_oauth = {_pack=(fun a -> `oauth(a))}
let msg_submit = {_pack=(fun a -> `submit(a))}
let msg_success = {_pack=(fun a -> `success(a))}
let msg_tokens = {_pack=(fun a -> `tokens(a))}
