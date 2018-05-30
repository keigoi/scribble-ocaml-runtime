open Linocaml_lwt
open Scribble_lwt
open Scribble_http_lwt

module Params = struct
  let oauth_start_url = "https://www.facebook.com/dialog/oauth"
  let client_id = "1491337000919429"
  let callback_url = "https://keigoimai.info/scribble/callback"
  let client_secret = "*****"
end

let acceptor, hook = http_acceptor ~base_path:"/scribble"

let () = Cohttp_server_lwt.hook := hook

module User = struct
  open Lwt

  type conn = Scribble_http_lwt.cohttp_server

  let conn = CohttpServer

  let read_oauth c =
      c.read_request ~paths:["/oauth"] () >>= fun (_req, _body) ->
      return ((`oauth(Data (), dummy)) : [`oauth of _])

  let write_302_oauth_start c =
    function
      | (`_302_oauth_start(Data state_, _)) ->
         let redirect_to =
           Uri.add_query_params'
             (Uri.of_string Params.oauth_start_url)
             [("client_id", Params.client_id);
              ("redirect_uri", Params.callback_url);
              ("state", state_)]
         in
         Cohttp_lwt_unix.Server.respond_string
           ~status:`Found
           ~headers:(Cohttp.Header.init_with "Location" @@ Uri.to_string redirect_to)
           ~body:"" () >>= fun (resp,body) ->
         c.write_response (resp, body)
      | _ -> failwith ""

  let read_callback_success_or_callback_fail c =
      c.read_request
        ~paths:["/callback"]
        ~predicate:(Util.http_parameter_contains ("state", "FIXME")) ()
      >>= fun (req, _body) ->

      Util.parse req >>= fun (path, query) ->

      match List.assoc_opt "code" query with
      | Some [code] ->
         return @@ (`callback_success(Data code, dummy) : [`callback_success of _ | `callback_fail of _])
      | _ ->
         return @@ `callback_fail(Data (), dummy)

  let write_200 c = function
      | (`_200(Data page, _)) ->
         Cohttp_lwt_unix.Server.respond_string
           ~status:`OK
           ~body:page ()
         >>= fun (resp,body) -> c.write_response (resp, body)
end

let connector = http_connector ~base_url:"https://graph.facebook.com/v2.11/oauth" ()

module Provider = struct
  open Lwt
  type conn = Scribble_http_lwt.cohttp_client
  type corr = string

  let conn = CohttpClient

  let write_access_token {write_request} =
       function
       | `access_token(Data (), _) ->
          write_request
            ~path:"/access_token"
            ~params:[("client_id", [Params.client_id]);
                     ("redirect_uri", [Params.callback_url]);
                     ("client_secret", [Params.client_secret]);
                     ("code", ["FIXME"])]
       | _ -> failwith ""

  let read_200 {read_response} =
       read_response >>= fun (_req, body) ->
       return @@ `_200 (Data body, dummy)
end
