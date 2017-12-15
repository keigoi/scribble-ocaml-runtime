(* request_stream part is from ocaml-cohttp where ISC license applies. *)
open Scribble_lwt
open Linocaml_lwt

type 'a ctx = <s : 'a>
[@@deriving lens]
[@@runner]

open OAuth

type cohttp_server_input_stream = (Cohttp.Request.t * string) Lwt_stream.t
type cohttp_client_input_stream = (Cohttp.Response.t * string) Lwt_stream.t

type cohttp_server = {in_srv:cohttp_server_input_stream; out_srv:Lwt_io.output_channel}
type cohttp_client = {in_cli:cohttp_client_input_stream; out_cli:Lwt_io.output_channel}

type _ Endpoint.conn_kind +=
       CohttpServer : cohttp_server Endpoint.conn_kind
   |   CohttpClient : cohttp_client Endpoint.conn_kind

(* from https://github.com/mirage/ocaml-cohttp/blob/v1.0.0/cohttp-lwt/src/server.ml#L73-L110
 * Copyright (c) 2012 Anil Madhavapeddy <anil@recoil.org>
 *)
let request_stream (ic : Lwt_io.input_channel) : cohttp_server_input_stream =
  let open Cohttp_lwt_unix in
  let open Lwt in
  (* don't try to read more from ic until the previous request has
       been fully read an released this mutex *)
  let read_m = Lwt_mutex.create () in
  (* If the request is HTTP version 1.0 then the request stream should be
       considered closed after the first request/response. *)
  let early_close = ref false in
  Lwt_stream.from begin fun () ->
    if !early_close
    then Lwt.return_none
    else
      Lwt_mutex.lock read_m >>= fun () ->
      Request.read ic >>= function
      | `Eof | `Invalid _ -> (* TODO: request logger for invalid req *)
         Lwt_mutex.unlock read_m;
         Lwt.return_none
      | `Ok req -> begin
          early_close := not (Request.is_keep_alive req);
          (* Ensure the input body has been fully read before reading
               again *)
          match Request.has_body req with
          | `Yes ->
             let reader = Request.make_body_reader req ic in
             let body_stream = Cohttp_lwt.Body.create_stream
                                 Request.read_body_chunk reader in
             Lwt_stream.on_terminate body_stream
               (fun () -> Lwt_mutex.unlock read_m);
             Cohttp_lwt.Body.to_string @@ Cohttp_lwt.Body.of_stream body_stream >>= fun body ->
             Lwt.return (Some (req, body))
          (* TODO for now we are just repeating the old behaviour
           * of ignoring the body in the request. Perhaps it should be
           * changed it did for responses *)
          | `No | `Unknown ->
             Lwt_mutex.unlock read_m;
             Lwt.return (Some (req, ""))
        end
    end

let write oc (res,body) =
  let open Cohttp_lwt_unix in
  let flush = Response.flush res in
  Response.write ~flush (fun writer ->
      Cohttp_lwt.Body.write_body (Response.write_body writer) body
    ) res oc

let listen ?(backlog=128) sa =
  let open Lwt in
  let fd = Lwt_unix.socket (Unix.domain_of_sockaddr sa) Unix.SOCK_STREAM 0 in
  Lwt_unix.(setsockopt fd SO_REUSEADDR true);
  Lwt_unix.bind fd sa >|= fun () ->
  Lwt_unix.listen fd backlog;
  Lwt_unix.set_close_on_exec fd;
  fd

let http_acceptor ?(host="0.0.0.0") ~port () : cohttp_server Endpoint.acceptor Lwt.t =
  let open Lwt in
  listen (Unix.ADDR_INET(Unix.inet_addr_of_string host, port)) >>= fun lfd ->
  Lwt.return @@ fun () ->
                print_endline "accept!!";
                Lwt_unix.accept lfd >>= fun (fd, peer_addr) ->
                Lwt_unix.setsockopt fd Lwt_unix.TCP_NODELAY true;
                Lwt.return
                  {Endpoint.handle=
                     {in_srv=request_stream @@ Lwt_io.of_fd Lwt_io.input fd;
                      out_srv=Lwt_io.of_fd Lwt_io.output fd};
                   close=(fun () -> Lwt_unix.close fd)}

(* TODO *)
let http_connector ~(host : string) () : cohttp_client Endpoint.connector =
  Obj.magic ()


(* TODO *)
module HttpParsersAndPrinters = struct
  module Receivers = struct
    open Lwt
    let _oauth {in_srv} =
      Lwt_stream.get in_srv >>= fun _ ->
      Lwt.return (`oauth(Data (), Obj.magic ()))

    let _login_fail_or_success {in_srv} =
      if true
      then
        Lwt.return (`login_fail(Data (Obj.magic ()), Obj.magic ()))
      else
        Lwt.return (`success(Data (Obj.magic ()), Obj.magic ()))

    let _200 {in_cli} =
      Lwt.return (`_200(Data (Obj.magic ()), Obj.magic ()))
  end
  module Senders = struct
    let _200 {out_srv} (`_200(_, Data _, _) : [`_200 of _]) =
      Lwt.return ()

    let _302 {out_srv} (`_302(_, Data _, _) : [`_302 of _]) =
      Lwt.return ()

    let _tokens {out_cli} (`tokens(_, Data _, _) : [`tokens of _]) =
      Lwt.return ()
  end
end
open HttpParsersAndPrinters

let oauth_provider acceptor =
  let role_U = mk_role_U CohttpServer in
  let role_A = mk_role_A CohttpClient in
  let%lin #s = initiate_C () in
  let%lin `oauth(_,#s) = accept s acceptor role_U in
  let%lin #s = send s role_U msg_302 ("","") in
  let%lin #s = disconnect s role_U in
  begin match%lin accept s acceptor role_U with
  | `login_fail(_, #s) ->
     let%lin #s = send s role_U msg_200 () in
     close s
  | `success(_, #s) ->
     let connector = http_connector ~host:"" () in (* TODO *)
     let%lin #s = connect s connector role_A msg_tokens (Obj.magic ()) in (* TODO *)
     let%lin `_200(_,#s) = receive s role_A in
     let%lin #s = disconnect s role_A in
     let%lin #s = send s role_U msg_200 () in
     let%lin #s = disconnect s role_U in
     close s
  end

let%lwt () =
  let open Lwt in
  let%lwt acceptor = http_acceptor ~port:8080 () in
  run_ctx oauth_provider acceptor
