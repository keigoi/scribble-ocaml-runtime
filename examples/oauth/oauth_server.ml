(* request_stream part is from ocaml-cohttp where ISC license applies. *)
open Scribble_lwt
open Linocaml_lwt

type 'a ctx = <s : 'a>
[@@deriving lens]
[@@runner]

open OAuth

type cohttp_server = {in_srv: ?pred:(Cohttp.Request.t -> bool) -> string list -> (Cohttp.Request.t * Cohttp_lwt.Body.t) Lwt.t;
                      out_srv: Cohttp.Response.t -> string -> unit Lwt.t}
type cohttp_client = {in_cli: Cohttp.Response.t * string Lwt.t;
                      out_cli: Cohttp.Request.t -> string -> unit Lwt.t}

type _ Endpoint.conn_kind +=
       CohttpServer : cohttp_server Endpoint.conn_kind
 |   CohttpClient : cohttp_client Endpoint.conn_kind

let start_server host port callback () =
  let open Lwt.Infix in
  let config = Cohttp_lwt_unix.Server.make ~callback () in
  Conduit_lwt_unix.init ~src:host () >>= fun ctx ->
  let ctx = Cohttp_lwt_unix.Net.init ~ctx () in
  Cohttp_lwt_unix.Server.create ~ctx ~mode:(`TCP (`Port port)) config

let in_mvar mvar f =
  let open Lwt.Infix in
  Lwt_mvar.take mvar >>= fun content ->
  Lwt.finalize (fun () ->
      f content) (fun () ->
      Lwt_mvar.put mvar content)

module ActionTable : sig
  type 'a t
  val create : unit -> 'a t
  val wait : 'a t -> pred:(Cohttp.Request.t -> bool) -> paths:string list -> 'a Lwt.t
  val dispatch : 'a t -> Cohttp.Request.t -> 'a -> unit Lwt.t
end = struct
  open Lwt
  type pred = Cohttp.Request.t -> bool
  type 'a t = (string, (pred * 'a Lwt.u) list) Hashtbl.t Lwt_mvar.t

  let create () = Lwt_mvar.create (Hashtbl.create 42)
  let wait tbl ~pred ~paths =
    in_mvar tbl begin fun hash ->
      let wait, wake = Lwt.wait () in
      let put path =
        print_endline @@ "put:" ^ path;
        begin match Hashtbl.find_opt hash path with
        | Some xs -> Hashtbl.replace hash path ((pred, wake)::xs)
        | None -> Hashtbl.add hash path [(pred,wake)]
        end
      in
      List.iter put paths;
      return wait
      end >>= fun wait ->
    wait
  let dispatch tbl req a =
    let path : string = req |> Cohttp.Request.resource |> Uri.of_string |> Uri.path in
    print_endline @@ "dispatch:"^ path;
    in_mvar tbl begin fun hash ->
      let w =
        match Hashtbl.find_opt hash path with
        | Some xs ->
           let rec loop acc = function
             | (f,w)::xs -> if f req
                            then (w, acc @ xs)
                            else loop ((f,w)::acc) xs
             | [] ->
                print_endline"path found but no action";
                failwith "path found but no action"
           in
           let w, xs = loop [] xs in
           Hashtbl.replace hash path xs;
           w
        | _ ->
           print_endline"path not found";
           failwith "no action"
      in
      return w
      end >>= fun w ->
    print_endline "found";
    Lwt.wakeup w a;
    print_endline "dispatch done";
    return ()
end

let http_acceptor ?(host="0.0.0.0") ~port () : cohttp_server Endpoint.acceptor Lwt.t =
  let open Lwt in
  let table = ActionTable.create () in
  let callback conn req body =
    print_endline "callback start";
    let wait, wake = Lwt.wait () in
    let outf resp body = Lwt.wakeup wake (resp, body)
    and clsf () = ()
    in
    print_endline "dispatch";
    ActionTable.dispatch table req ((req,body), outf, clsf) >>= fun () ->
    print_endline "dispatched";
    wait
  in
  Lwt.async (start_server host port callback);
  let wait_for_client ?(pred=fun _->true) ~paths =
    print_endline @@ "wait for" ^ List.hd paths;
    ActionTable.wait table ~pred ~paths
  in
  Lwt.return @@
    (fun () ->
      print_endline "accept!";
      let wait1, wake1 = Lwt.wait () in
      let wait2, wake2 = Lwt.wait () in
      return
        {Endpoint.handle={
           in_srv=(fun ?pred paths ->
             print_endline "wait for client";
             wait_for_client ?pred ~paths >>= fun (in_,outf,clsf) ->
             print_endline "woken up";
             Lwt.wakeup wake1 outf;
             Lwt.wakeup wake2 clsf;
             return in_);
           out_srv=(fun head body -> if Lwt.state wait1 = Sleep then failwith "write: no request" else wait1 >>= fun f -> Lwt.return (f head (`String(body))))};
         close=(fun () -> if Lwt.state wait2 = Sleep then failwith "close: no request" else wait2 >>= fun f -> Lwt.return (f ()))}
    )

(* TODO *)
let http_connector ~(host : string) () : cohttp_client Endpoint.connector =
  failwith "http_connector unimplemented"


(* TODO *)
module HttpParsersAndPrinters = struct
  module Receivers = struct
    open Lwt
    open Cohttp_lwt_unix

    let _oauth {in_srv} =
      print_endline "waiting /oauth";
      in_srv ["/oauth"] >>= fun (req,body) ->
      Request.sexp_of_t req |> Sexplib.Sexp.to_string |> print_endline;
      Lwt.return (`oauth(Data (), dummy))

    let _login_fail_or_success ({in_srv}, cookie) =
      print_endline "before login_fail_or_success";
      in_srv ~pred:(fun _ -> true)
        ["/login_fail"; "/success"] >>= fun (req, body)  ->
      print_endline "login_fail_or_success";
      match req |> Request.resource |> Uri.of_string |> Uri.path  with
      | "/login_fail" ->
         print_endline "login_fail";
         Lwt.return @@ `login_fail(Data "", dummy)
      | "/success" ->
         print_endline "success";
         Lwt.return @@ `success(Data ("", ""), dummy)
      | _ -> raise AcceptAgain

    let _200 {in_cli} =
      failwith "receive 200: not implemented"
      (* Lwt.return (`_200(Data (Obj.magic ()), Obj.magic ())) *)
  end
  module Senders = struct
    let _200 {out_srv} (`_200(_, Data _, _) : [`_200 of _]) =
      out_srv (Cohttp.Response.make ()) "hello world"

    let _302 {out_srv} (`_302(_, Data (url, backurl), _) : [`_302 of _]) =
      print_endline "302";
      out_srv (Cohttp.Response.make
                    ~status:(`Found)
                    ~headers:(Cohttp.Header.init_with "Location" url) ()) ""

    let _tokens {out_cli} (`tokens(_, Data _, _) : [`tokens of _]) =
      Lwt.return ()
  end
end

open HttpParsersAndPrinters

let oauth_provider acceptor =
  let open Linocaml_lwt in
  let role_U = mk_role_U CohttpServer in
  let role_A = mk_role_A CohttpClient in
  (* let%lin #s = Scribble_lwt.Internal.__initiate ~myname:"role_C" in *)
  let%lin #s = initiate_C () in
  let%lin `oauth(_,#s) = accept s acceptor role_U in
  let cookie = "123abc" in
  let%lin #s = send s role_U msg_302 ("https://api.twitter.com/oauth/authenticate?oauth_token=","") in
  let%lin #s = disconnect s role_U in
  begin match%lin accept_corr s acceptor role_U cookie with
  | `login_fail(_, #s) ->
     let%lin #s = send s role_U msg_200 () in
     close s
  | `success(_, #s) ->
     let connector = http_connector ~host:"" () in (* TODO *)
     let%lin #s = connect s connector role_A msg_tokens "" in (* TODO *)
     let%lin `_200(_,#s) = receive s role_A in
     let%lin #s = disconnect s role_A in
     let%lin #s = send s role_U msg_200 () in
     let%lin #s = disconnect s role_U in
     close s
  end

let () =
  Lwt_main.run
    begin
      let open Lwt in
      http_acceptor ~port:8080 () >>= fun acceptor ->
      run_ctx oauth_provider acceptor
    end
