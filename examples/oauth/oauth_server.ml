(* request_stream part is from ocaml-cohttp where ISC license applies. *)
open Scribble_lwt
open Linocaml_lwt

type 'a ctx = <s : 'a>
[@@deriving lens]
[@@runner]

open OAuth

type cohttp_request_stream = (Cohttp.Request.t * string) Lwt_stream.t
type cohttp_response_stream = (Cohttp.Response.t * string) Lwt_stream.t

type cohttp_server = {in_srv:cohttp_request_stream; out_srv: Cohttp.Response.t * string -> unit Lwt.t}
type cohttp_client = {in_cli:cohttp_response_stream; out_cli:Lwt_io.output_channel}

type _ Endpoint.conn_kind +=
       CohttpServer : cohttp_server Endpoint.conn_kind
   |   CohttpClient : cohttp_client Endpoint.conn_kind

(* from https://github.com/mirage/ocaml-cohttp/blob/v1.0.0/cohttp-lwt/src/server.ml#L73-L110
 * Copyright (c) 2012 Anil Madhavapeddy <anil@recoil.org>
 *)
let request_stream (ic : Lwt_io.input_channel) : cohttp_request_stream =
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

let response oc (resp,body) =
  let open Lwt in
  let flush = Cohttp.Response.flush resp in
  Cohttp_lwt_unix.Response.write ~flush (fun writer ->
      Cohttp_lwt.Body.write_body (Cohttp_lwt_unix.Response.write_body writer) (Cohttp_lwt.Body.of_string body)
    ) resp oc >>= fun _ ->
  Lwt_io.flush oc

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
  let process_callers_body waitors(* queue of stream push funcs *) conn =
    let rest_waitors = Queue.create () in
    let rec loop () =
      if Queue.is_empty waitors then
        return false
      else begin
          let push_stream_func = Queue.pop waitors in
          let wait, wake = Lwt.wait () in
          push_stream_func (Some (conn, wake));
          wait >>= fun b ->
          if b then begin
              Queue.transfer waitors rest_waitors;
              return true
            end else begin
              Queue.push push_stream_func rest_waitors;
              loop ()
            end
        end
    in
    loop () >>= fun b ->
    return (b, rest_waitors)
  in
  let waitors = Lwt_mvar.create (Queue.create ()) in
  let process_waitors conn =
    Lwt_mvar.take waitors >>= fun wq ->
    Lwt_mvar.put waitors (Queue.create ()) >>= fun _ ->
    process_callers_body wq conn >>= fun (b, wq_rest) ->
    Lwt_mvar.take waitors >>= fun new_wq ->
    Queue.transfer new_wq wq_rest;
    Lwt_mvar.put waitors wq_rest >>= fun _ ->
    return b
  in
  let rec loop () =
    print_endline "accept!!";
    Lwt_unix.accept lfd >>= fun (fd, peer_addr) ->
    Lwt_unix.setsockopt fd Lwt_unix.TCP_NODELAY true;
    print_endline "accepted!!";
    let conn = {Endpoint.handle=
                  {in_srv=request_stream @@ Lwt_io.of_fd Lwt_io.input fd;
                   out_srv=response (Lwt_io.of_fd Lwt_io.output fd)};
                close=(fun () -> Lwt_unix.close fd)}
    in
    process_waitors conn >>= fun b ->
    if not b then ignore @@ begin
        print_endline "no handler";
        conn.Endpoint.handle.out_srv @@ (Cohttp.Response.make (), "") >>= fun _ ->
        conn.Endpoint.close ()
      end;
    loop ()
  in
  Lwt.async loop;
  let make_conn_stream () =
    let st, push_st = Lwt_stream.create () in
    Lwt_mvar.take waitors >>= fun wq -> Queue.push push_st wq; Lwt_mvar.put waitors wq >>= fun () ->
    return st
  in
  Lwt.return @@
    {Endpoint.try_accept=(fun predicate ->
       make_conn_stream () >>= fun conn_stream ->
       print_endline "Acceptor made";
       let rec loop () =
         Lwt_stream.get conn_stream >>= function None -> assert false | Some (conn, ret) ->
         predicate conn >>= function
         | Some c -> Lwt.wakeup ret true; return c
         | None ->
            Lwt.wakeup ret false;
            loop ()
       in loop ())}

(* TODO *)
let http_connector ~(host : string) () : cohttp_client Endpoint.connector =
  Obj.magic ()


(* TODO *)
module HttpParsersAndPrinters = struct
  module Receivers = struct
    open Lwt
    open Cohttp_lwt_unix

    let _oauth {in_srv} =
      Lwt_stream.get in_srv >>= function
      | (Some({Request.resource="/oauth"} as req,_)) ->
         print_endline (Sexplib.Sexp.to_string @@ Cohttp.Request.sexp_of_t req);
         Lwt.return (`oauth(Data (), dummy))
      | _ -> raise AcceptAgain

    let _login_fail_or_success {in_srv} =
      Lwt_stream.get in_srv >>= function
      | (Some({Request.resource="/login_fail"} as req,_)) ->
         print_endline "login_fail";
         print_endline (Sexplib.Sexp.to_string @@ Cohttp.Request.sexp_of_t req);
         Lwt.return @@ `login_fail(Data (Obj.magic ()), dummy)
      | (Some({Request.resource="/success"} as req,_)) ->
         print_endline "success";
         print_endline (Sexplib.Sexp.to_string @@ Cohttp.Request.sexp_of_t req);
         Lwt.return @@ `success(Data (Obj.magic ()), dummy)
      | _ -> raise AcceptAgain

    let _200 {in_cli} =
      Lwt.return (`_200(Data (Obj.magic ()), Obj.magic ()))
  end
  module Senders = struct
    let _200 {out_srv} (`_200(_, Data _, _) : [`_200 of _]) =
      out_srv @@ (Cohttp.Response.make (), "hello world")

    let _302 {out_srv} (`_302(_, Data (url, backurl), _) : [`_302 of _]) =
      out_srv @@ (Cohttp.Response.make
                    ~status:(`Found)
                    ~headers:(Cohttp.Header.init_with "Location" url) (), "")

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
  let%lin #s = send s role_U msg_302 ("https://api.twitter.com/oauth/authenticate?oauth_token=","") in
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
