(* request_stream part is from ocaml-cohttp where ISC license applies. *)
open Linocaml_lwt
open Scribble_lwt
open Scribble_http_lwt

open OAuth

module HttpParsersAndPrinters
         (M:sig
              val oauth_start_url_base : string
              val client_id : string
              val client_secret : string
            end) = struct

  module Receivers = struct

    open Lwt

    let _oauth {base_url; in_srv} =
      let%lwt _ = in_srv ~paths:["/oauth"] () in
      return (`oauth(Data (), dummy))

    let _callback_fail_or_success ({base_url; in_srv}, state) =
      let%lwt path, query =
        parse @@ in_srv
                   ~pred:(http_parameter_contains ("state", state))
                   ~paths:["/callback"] ()
      in
      match List.assoc_opt "code" query with
      | Some [code] ->
         let redir_url = base_url^ "/callback" in
         return @@ `callback_success(Data (redir_url, code), dummy)
      | _ ->
         return @@ `callback_fail(Data (), dummy)

    let _200 {in_cli} =
      let%lwt _req, body = in_cli in
      return @@ `_200 (Data body, dummy)

  end

  module Senders = struct

    let _302_oauth_start {base_url; out_srv} (`_302_oauth_start(_, Data state, _) : [`_302_oauth_start of _]) =
      let my_callback_url = base_url ^ "/callback" in
      let redir_url = Uri.of_string M.oauth_start_url_base in
      let redir_url =
        Uri.add_query_params' redir_url
          [("client_id", M.client_id); ("redirect_uri", my_callback_url); ("state", state)]
      in
      out_srv @@
        Cohttp_lwt_unix.Server.respond_string
          ~status:`Found
          ~headers:(Cohttp.Header.init_with "Location" @@ Uri.to_string redir_url)
          ~body:"" ()

    let _200 {out_srv} (`_200(_, Data page, _) : [`_200 of _]) =
      let open Lwt in
      out_srv @@
        Cohttp_lwt_unix.Server.respond_string ~status:`OK ~body:page ()

    let _access_token ({out_cli}, (redir_url, code)) (`access_token(_, Data (), _) : [`access_token of _]) =
      out_cli
        ~path:"/access_token"
        ~params:[("client_id", [M.client_id]);
                 ("redirect_uri", [redir_url]);
                 ("client_secret", [M.client_secret]);
                 ("code", [code])]
  end
end

module M = HttpParsersAndPrinters(struct
               let oauth_start_url_base = "https://www.facebook.com/dialog/oauth"
               let client_id = "1491337000919429"
               let client_secret = "*"
             end)
open M


type 'a ctx = <s : 'a>
                     [@@deriving lens]
                       [@@runner]

let oauth_consumer acceptor connector () =

  let open Linocaml_lwt in
  let role_U = mk_role_U CohttpServer in
  let role_P = mk_role_P CohttpClient in

  let%lin #s = initiate_C () in

  let%lin `oauth(_, #s) = accept s acceptor role_U in
  let state = "123abc" in
  let%lin #s = send s role_U msg_302_oauth_start state in
  let%lin #s = disconnect s role_U in

  begin match%lin accept_corr s acceptor state role_U with
  | `callback_fail(_, #s) ->
     let%lin #s = send s role_U msg_200 "Authentication failure" in
     close s

  | `callback_success(code, #s) ->
     let url, code_ = code in
     print_endline @@ "callback_success,"^url^","^code_;
     let%lin #s = connect_corr s connector code role_P msg_access_token () in
     let%lin `_200(_,#s) = receive s role_P in
     let%lin #s = disconnect s role_P in
     let%lin #s = send s role_U msg_200 "Success" in
     let%lin #s = disconnect s role_U in
     close s
  end


let () =
  Lwt_main.run
    begin
      let open Lwt in
      let%lwt acceptor = http_acceptor ~port:8080 ~base_url:"https://keigoimai.info/scribble" () in
      let connector = http_connector ~base_url:"https://graph.facebook.com/v2.11/oauth" () in
      run_ctx (oauth_consumer acceptor connector) ()
    end
