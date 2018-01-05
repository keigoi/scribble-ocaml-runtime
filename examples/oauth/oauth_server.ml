(* request_stream part is from ocaml-cohttp where ISC license applies. *)
open Linocaml_lwt
open Scribble_lwt
open Scribble_http_lwt

module M = OAuth.Make(Scribble_lwt)(struct
               type id = string
               and pass = string
               and state = string
               and code = string * string
               and accessToken = string
               and page = string
             end)
open M

module type OAuthParserPrinterParams = sig
  val oauth_start_url : string
  val callback_url : string (* must end with "/callback" *)
  val client_id : string
  val client_secret : string
end

module OAuthParserPrinter(M:OAuthParserPrinterParams) = struct

  let http_parameter_contains (key,value) req =
    let uri = req |> Cohttp.Request.resource |> Uri.of_string in
    Uri.get_query_param uri key = Some value

  let parse (req, _body) =
    let uri = req |> Cohttp.Request.resource |> Uri.of_string in
    Lwt.return Uri.(path uri, Uri.query uri)

  module Receivers = struct
    open Lwt

    let _oauth {read_request} =
      let%lwt _ = read_request ~paths:["/oauth"] () in
      return (`oauth(Data (), dummy))

    let _callback_fail_or_success ({read_request}, state) =
      let%lwt path, query =
        read_request
          ~pred:(http_parameter_contains ("state", state))
          ~paths:["/callback"] ()
        >>= parse
      in
      match List.assoc_opt "code" query with
      | Some [code] ->
         return @@ `callback_success(Data code, dummy)
      | _ ->
         return @@ `callback_fail(Data (), dummy)

    let _200 {read_response} =
      let%lwt _req, body = read_response in
      return @@ `_200 (Data body, dummy)

  end

  module Senders = struct
    open Lwt

    let _302_oauth_start {write_response} (`_302_oauth_start(_, Data state, _) : [`_302_oauth_start of _]) =
      let redir_url = Uri.of_string M.oauth_start_url in
      let redir_url =
        Uri.add_query_params' redir_url
          [("client_id", M.client_id); ("redirect_uri", M.callback_url); ("state", state)]
      in
      Cohttp_lwt_unix.Server.respond_string
        ~status:`Found
        ~headers:(Cohttp.Header.init_with "Location" @@ Uri.to_string redir_url)
        ~body:"" () >>=
        write_response

    let _200 {write_response} (`_200(_, Data page, _) : [`_200 of _]) =
      Cohttp_lwt_unix.Server.respond_string ~status:`OK ~body:page () >>=
        write_response

    let _access_token ({write_request}, code) (`access_token(_, Data (), _) : [`access_token of _]) =
      write_request
        ~path:"/access_token"
        ~params:[("client_id", [M.client_id]);
                 ("redirect_uri", [M.callback_url]);
                 ("client_secret", [M.client_secret]);
                 ("code", [code])]
  end
end



type 'a ctx = <s : 'a>
                     [@@deriving lens]
                       [@@runner]

let oauth_consumer (module M:OAuthParserPrinterParams) acceptor connector () =
  let module P = OAuthParserPrinter(M) in (* import type class instances *)
  let open P in

  let open Linocaml_lwt in
  let role_U = mk_role_U CohttpServer in
  let role_P = mk_role_P CohttpClient in

  let%lin #s = initiate_C () in

  let%lin `oauth(_, #s) = accept s acceptor role_U in
  let state = Printf.sprintf "%x" (Random.bits ())  in
  let%lin #s = send s role_U msg_302_oauth_start state in
  let%lin #s = disconnect s role_U in

  begin match%lin accept_corr s acceptor state role_U with
  | `callback_fail(_, #s) ->
     let%lin #s = send s role_U msg_200 "Authentication failure" in
     close s

  | `callback_success(code, #s) ->
     let%lin #s = connect_corr s connector code role_P msg_access_token () in
     let%lin `_200(accessToken,#s) = receive s role_P in
     let%lin #s = disconnect s role_P in
     let%lin #s = send s role_U msg_200 ("OAuth successful. Accsss Token response:" ^ accessToken) in
     let%lin #s = disconnect s role_U in
     close s
  end

let acceptor, hook =
  http_acceptor ~base_path:"/scribble"

let () =
  Cohttp_server_lwt.hook := hook

let _ =
  let module Params = struct
      let oauth_start_url = "https://www.facebook.com/dialog/oauth"
      let callback_url = "https://keigoimai.info/scribble/callback"
      let client_id = "1491337000919429"
      let client_secret = "*****"
    end
  in
  let connector = http_connector ~base_url:"https://graph.facebook.com/v2.11/oauth" () in
  let rec loop () =
    let open Lwt in
    run_ctx (oauth_consumer (module Params) acceptor connector) () >>= fun () ->
    loop ()
  in loop ()


let () =
  print_endline "running cohttp server";
  match Cmdliner.Term.eval Cohttp_server_lwt.cmd with
  | `Error _ -> exit 1
  | _ -> exit 0
