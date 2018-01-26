open Linocaml_lwt
open Scribble_lwt
open Scribble_http_lwt

module Protocol =
  OAuth.Make(Scribble_lwt)(struct type page = string end)

module Params = struct
  let oauth_start_url = "https://www.facebook.com/dialog/oauth"
  let callback_url = "https://keigoimai.info/scribble/callback"
  let client_id = "1491337000919429"
  let client_secret = "*****"
end


module U = struct
  open Lwt

  let role = {_pack_role=(fun labels -> `U(labels)) ; _repr="role_U"; _kind=CohttpServer}

  let receive_oauth =
    {_receive = (fun c ->
       c.read_request ~paths:["/oauth"] () >>= fun (_req, _body) ->
       return (`oauth(Data (), dummy))
    )}

  let _302_oauth_start =
    {_pack_label = (fun payloads -> `_302_oauth_start(payloads));
     _send = (fun c data ->
       match data with
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
    )}

  let receive_callback_success_or_callback_fail =
    {_receive = (fun (c, state) ->
       c.read_request
         ~paths:["/callback"]
         ~predicate:(Util.http_parameter_contains ("state", state)) () >>= fun (req, _body) ->

       Util.parse req >>= fun (path, query) ->

       match List.assoc_opt "code" query with
       | Some [code] ->
          return @@ `callback_success(Data code, dummy)
       | _ ->
          return @@ `callback_fail(Data (), dummy)
    )}

  let _200 =
    {_pack_label = (fun payloads -> `_200(payloads));
     _send = (fun c data ->
       match data with
       | (`_200(Data page, _)) ->
          Cohttp_lwt_unix.Server.respond_string
            ~status:`OK
            ~body:page () >>= fun (resp,body) ->
          c.write_response (resp, body)
    )}

end

module P = struct
  open Lwt

  let role = {_pack_role=(fun labels -> `P(labels)) ; _repr="role_P"; _kind=CohttpClient}

  let access_token =
    {_pack_label = (fun payload -> `access_token(payload));
     _send = (fun ({write_request},code) ->
       function
       | `access_token(Data (), _) ->
          write_request
            ~path:"/access_token"
            ~params:[("client_id", [Params.client_id]);
                     ("redirect_uri", [Params.callback_url]);
                     ("client_secret", [Params.client_secret]);
                     ("code", [code])]
       | _ -> failwith ""
    )}

  let receive_200 =
    {_receive = (fun {read_response} ->
       read_response >>= fun (_req, body) ->
       return @@ `_200 (Data body, dummy)
    )}
end


type 'a ctx = <s : 'a>
[@@deriving lens]
[@@runner]

let oauth_consumer acceptor connector () =
  let%lin #s = Protocol.C.initiate_C () in

  let%lin `oauth(_, #s) = s ^^ accept (U.role, U.receive_oauth) acceptor in
  let state = Printf.sprintf "%x" (Random.bits ())  in
  let%lin #s = s ^^ send (U.role, U._302_oauth_start, state) in
  let%lin #s = s ^^ disconnect U.role in

  begin match%lin s ^^ accept_corr (U.role, U.receive_callback_success_or_callback_fail, state) acceptor with
  | `callback_fail(_, #s) ->
     let%lin #s = s ^^ send (U.role, U._200, "Authentication failure") in
     s ^^ close

  | `callback_success(code, #s) ->
     let%lin #s = s ^^ connect_corr (P.role, P.access_token, code, ()) connector in
     let%lin `_200(accessToken,#s) = s ^^ receive (P.role, P.receive_200) in
     let%lin #s = s ^^ disconnect P.role in
     let%lin #s = s ^^ send (U.role, U._200, "OAuth successful. Accsss Token response:" ^ accessToken) in
     let%lin #s = s ^^ disconnect U.role in
     s ^^ close
  end

let acceptor, hook =
  http_acceptor ~base_path:"/scribble"

let () =
  Cohttp_server_lwt.hook := hook

let _ =
  let connector = http_connector ~base_url:"https://graph.facebook.com/v2.11/oauth" () in
  let rec loop () =
    let open Lwt in
    run_ctx (oauth_consumer acceptor connector) () >>= fun () ->
    loop ()
  in loop ()


let () =
  print_endline "running cohttp server";
  match Cmdliner.Term.eval Cohttp_server_lwt.cmd with
  | `Error _ -> exit 1
  | _ -> exit 0
