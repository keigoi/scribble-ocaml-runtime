(* Generated from scribble-ocaml https://github.com/keigoi/scribble-ocaml
 * This code should be compiled with scribble-ocaml-runtime
 * https://github.com/keigoi/scribble-ocaml-runtime *)
open Scribble

type oAuth

module type TYPES = sig
  type page
end

module Make(Session:Scribble.Base.SESSION)(Types:TYPES) = struct

  type id = string
  and pass = string
  and state = string
  and code = string
  and accessToken = string
  and page = Types.page

  open Session

type ('c_C, 'c_P) oAuth_U = ('c_C, 'c_P) oAuth_U_1
and ('c_C, 'c_P) oAuth_U_1 =
  [`send of
    [`oauth of ([`C], 'c_C) role connect * unit data *
      [`recv of ([`C], 'c_C) role * [`_302_oauth_start of state data *
        [`disconnect of ([`C], 'c_C) role *
          [`send of
            [`authorize_request of ([`P], 'c_P) role connect * state data *
              [`recv of ([`P], 'c_P) role * [`_200 of page data *
                [`disconnect of ([`P], 'c_P) role *
                  [`send of
                    [`submit of ([`P], 'c_P) role connect * (id * pass) data *
                      [`recv of ([`P], 'c_P) role *
                        [`_302_success of code data *
                          [`disconnect of ([`P], 'c_P) role *
                            [`send of
                              [`callback_success of ([`C], 'c_C) role connect * code data *
                                [`recv of ([`C], 'c_C) role * [`_200 of page data *
                                  [`disconnect of ([`C], 'c_C) role *
                                    [`close] sess] sess]] sess]] sess] sess
                        |`_302_fail of unit data *
                          [`disconnect of ([`P], 'c_P) role *
                            [`send of
                              [`callback_fail of ([`C], 'c_C) role connect * unit data *
                                [`recv of ([`C], 'c_C) role * [`_200 of page data *
                                  [`close] sess]] sess]] sess] sess]] sess]] sess] sess]] sess]] sess] sess]] sess]]
type ('c_U, 'c_P) oAuth_C = ('c_U, 'c_P) oAuth_C_1
and ('c_U, 'c_P) oAuth_C_1 =
  [`accept of ([`U], 'c_U) role *
    [`oauth of unit data *
      [`send of
        [`_302_oauth_start of ([`U], 'c_U) role * state data *
          [`disconnect of ([`U], 'c_U) role *
            [`accept of ([`U], 'c_U) role *
              [`callback_success of code data *
                [`send of
                  [`access_token of ([`P], 'c_P) role connect * unit data *
                    [`recv of ([`P], 'c_P) role * [`_200 of accessToken data *
                      [`disconnect of ([`P], 'c_P) role *
                        [`send of
                          [`_200 of ([`U], 'c_U) role * page data *
                            [`disconnect of ([`U], 'c_U) role *
                              [`close] sess] sess]] sess] sess]] sess]] sess
              |`callback_fail of unit data *
                [`send of
                  [`_200 of ([`U], 'c_U) role * page data *
                    [`close] sess]] sess]] sess] sess]] sess]]
type ('c_U, 'c_C) oAuth_P = ('c_U, 'c_C) oAuth_P_1
and ('c_U, 'c_C) oAuth_P_1 =
  [`accept of ([`U], 'c_U) role *
    [`authorize_request of state data *
      [`send of
        [`_200 of ([`U], 'c_U) role * page data *
          [`disconnect of ([`U], 'c_U) role *
            [`accept of ([`U], 'c_U) role *
              [`submit of (id * pass) data *
                [`send of
                  [`_302_success of ([`U], 'c_U) role * code data *
                    [`disconnect of ([`U], 'c_U) role *
                      [`accept of ([`C], 'c_C) role *
                        [`access_token of unit data *
                          [`send of
                            [`_200 of ([`C], 'c_C) role * accessToken data *
                              [`disconnect of ([`C], 'c_C) role *
                                [`close] sess] sess]] sess]] sess] sess
                  |`_302_fail of ([`U], 'c_U) role * unit data *
                    [`disconnect of ([`U], 'c_U) role *
                      [`close] sess] sess]] sess]] sess] sess]] sess]]

let mk_role_U c : ([`U], _) role = Internal.__mkrole c "role_U"
let mk_role_C c : ([`C], _) role = Internal.__mkrole c "role_C"
let mk_role_P c : ([`P], _) role = Internal.__mkrole c "role_P"

let initiate_U : unit -> ('c, 'c, ('c_C, 'c_P) oAuth_U sess) monad =
  fun () ->
  Internal.__initiate ~myname:"role_U"
let initiate_C : unit -> ('c, 'c, ('c_U, 'c_P) oAuth_C sess) monad =
  fun () ->
  Internal.__initiate ~myname:"role_C"
let initiate_P : unit -> ('c, 'c, ('c_U, 'c_C) oAuth_P sess) monad =
  fun () ->
  Internal.__initiate ~myname:"role_P"

let msg_none = {_pack=(fun a -> `msg(a))}
let msg_200 = {_pack=(fun a -> `_200(a))}
let msg_302_fail = {_pack=(fun a -> `_302_fail(a))}
let msg_302_oauth_start = {_pack=(fun a -> `_302_oauth_start(a))}
let msg_302_success = {_pack=(fun a -> `_302_success(a))}
let msg_access_token = {_pack=(fun a -> `access_token(a))}
let msg_authorize_request = {_pack=(fun a -> `authorize_request(a))}
let msg_callback_fail = {_pack=(fun a -> `callback_fail(a))}
let msg_callback_success = {_pack=(fun a -> `callback_success(a))}
let msg_oauth = {_pack=(fun a -> `oauth(a))}
let msg_submit = {_pack=(fun a -> `submit(a))}
end
