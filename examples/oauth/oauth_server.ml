open Linocaml_lwt
open Scribble_lwt
open Scribble_http_lwt

module OAuth = OAuth.Make(Scribble_lwt)(struct type page = string end)

module U = OAuth.C.U.Make(Oauth_http.User)
module P = OAuth.C.P.Make(Oauth_http.Provider)

type ('a,'b,'c) ctx = <s : 'a; t : 'b; u : 'c> [@@deriving lens][@@runner]

let oauth_consumer () =
  OAuth.C.initiate_C () >>= fun%lin #s ->

  s ^^ accept Oauth_http.acceptor (U.role, U.receive_oauth) >>= fun%lin (`oauth(_, #s)) ->

  (* generate a session identifier *)
  let state = Printf.sprintf "%x" (Random.bits ())  in

  s ^^ send (U.role, U._302_oauth_start, state) >>= fun%lin #s ->

  s ^^ disconnect U.role >>= fun%lin #s ->

  s ^^ accept (*_corr*) Oauth_http.acceptor (U.role, U.receive_callback_success_or_callback_fail(*, state*))

     >>= function%lin
          | `callback_fail(_, #s) ->
             s ^^ send (U.role, U._200, "Authentication failure") >>= fun%lin #s ->
             s ^^ close
          | `callback_success(code, #s) ->
             s ^^ connect(*_corr*) Oauth_http.connector (P.role, P.access_token, (*code,*) ()) >>= fun%lin #s ->
             s ^^ receive (P.role, P.receive_200) >>= fun%lin (`_200(accessToken,#s)) ->
             s ^^ disconnect P.role >>= fun%lin #s ->
             s ^^ send (U.role, U._200, "OAuth successful. Accsss Token response:" ^ accessToken) >>= fun%lin #s ->
             s ^^ disconnect U.role >>= fun%lin #s ->
             s ^^ close

let _ =
  let rec loop () =
    let open Lwt in
    run_ctx oauth_consumer () >>= fun () ->
    loop ()
  in loop ()


let () =
  print_endline "running cohttp server";
  match Cmdliner.Term.eval Cohttp_server_lwt.cmd with
  | `Error _ -> exit 1
  | _ -> exit 0
