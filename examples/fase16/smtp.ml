(* Generated from scribble-ocaml https://github.com/keigoi/scribble-ocaml
 * This code should be compiled with session-ocaml (multiparty)
 * https://github.com/keigoi/session-ocaml/tree/multiparty *)
open Multiparty
type smtp

type smtp_C = smtp_C_1
and smtp_C_1 = 
  [`recv of [`S] role * [`_220 of unit data *
    [`send of
      [`Ehlo of [`S] role * unit data *
        smtp_C_2 sess]] sess]]
and smtp_C_2 = 
  [`recv of [`S] role *
    [`_250d of unit data *
      smtp_C_2 sess
    |`_250 of unit data *
      [`send of
        [`StartTls of [`S] role * unit data *
          [`recv of [`S] role * [`_220 of unit data *
            [`send of
              [`Ehlo of [`S] role * unit data *
                smtp_C_3 sess]] sess]] sess]] sess]]
and smtp_C_3 = 
  [`recv of [`S] role *
    [`_250d of unit data *
      smtp_C_3 sess
    |`_250 of unit data *
      [`send of
        [`Quit of [`S] role * unit data *
          [`close] sess]] sess]]
type smtp_S = smtp_S_1
and smtp_S_1 = 
  [`send of
    [`_220 of [`C] role * unit data *
      [`recv of [`C] role * [`Ehlo of unit data *
        smtp_S_2 sess]] sess]]
and smtp_S_2 = 
  [`send of
    [`_250d of [`C] role * unit data *
      smtp_S_2 sess
    |`_250 of [`C] role * unit data *
      [`recv of [`C] role * [`StartTls of unit data *
        [`send of
          [`_220 of [`C] role * unit data *
            [`recv of [`C] role * [`Ehlo of unit data *
              smtp_S_3 sess]] sess]] sess]] sess]]
and smtp_S_3 = 
  [`send of
    [`_250d of [`C] role * unit data *
      smtp_S_3 sess
    |`_250 of [`C] role * unit data *
      [`recv of [`C] role * [`Quit of unit data *
        [`close] sess]] sess]]

let role_C : [`C] role = Internal.__mkrole "smtp_C"
let role_S : [`S] role = Internal.__mkrole "smtp_S"

let accept_S : 'pre 'post. (smtp,[`ConnectFirst]) channel -> bindto:(empty, smtp_S sess, 'pre, 'post) slot -> ('pre,'post,unit) monad =
  fun ch ->
  Internal.__accept ~myname:"smtp_S" ~cli_count:1 ch

let connect_C : 'pre 'post. (smtp,[`ConnectFirst]) channel -> bindto:(empty, smtp_C sess, 'pre, 'post) slot -> ('pre,'post,unit) monad =
  fun ch ->
  Internal.__connect ~myname:"smtp_C" ch

let new_channel_smtp : unit -> (smtp,[`ConnectFirst]) channel = new_channel
let msg_220 = {_pack=(fun a -> `_220(a))}
let msg_250d = {_pack=(fun a -> `_250d(a))}
let msg_Ehlo = {_pack=(fun a -> `Ehlo(a))}
let msg_Quit = {_pack=(fun a -> `Quit(a))}
let msg_250 = {_pack=(fun a -> `_250(a))}
let msg_StartTls = {_pack=(fun a -> `StartTls(a))}
