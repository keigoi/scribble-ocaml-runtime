open Scribble_lwt

type cohttp_server =
  {base_url:string;
   in_srv:
     ?pred:(Cohttp.Request.t -> bool) -> paths:string list -> unit -> (Cohttp.Request.t * Cohttp_lwt.Body.t) Lwt.t;
   out_srv: (Cohttp.Response.t * Cohttp_lwt.Body.t) Lwt.t -> unit Lwt.t}

type cohttp_client =
  {in_cli: (Cohttp.Response.t * string) Lwt.t;
   out_cli: path:string -> params:(string * string list) list -> unit Lwt.t}

type _ Endpoint.conn_kind +=
       CohttpServer : cohttp_server Endpoint.conn_kind
   | CohttpClient : cohttp_client Endpoint.conn_kind

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
  val wait : 'a t -> pred:(Cohttp.Request.t -> bool) -> base_path:string -> paths:string list -> 'a Lwt.t
  val dispatch : 'a t -> Cohttp.Request.t -> 'a -> unit Lwt.t
end = struct
  open Lwt
  type pred = Cohttp.Request.t -> bool
  type 'a t = (string, (pred * 'a Lwt.u) list) Hashtbl.t Lwt_mvar.t

  let create () = Lwt_mvar.create (Hashtbl.create 42)
  let wait tbl ~pred ~base_path ~paths =
    in_mvar tbl begin fun hash ->
      let wait, wake = Lwt.wait () in
      let put path =
        let path = base_path ^ path in
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


let http_acceptor ?(base_url="FIXME") ?(host="0.0.0.0") ~port () : cohttp_server Endpoint.acceptor Lwt.t =
  let open Lwt in
  let table = ActionTable.create () in
  let callback conn req body =
    print_endline "callback start";
    let wait, wake = Lwt.wait () in
    let outf (resp, body) = Lwt.wakeup wake (resp, body); Lwt.return ()
    and clsf () = ()
    in
    print_endline @@ "dispatch:" ^ (req.Cohttp_lwt.Request.resource);
    ActionTable.dispatch table req ((req,body), outf, clsf) >>= fun () ->
    print_endline @@ "dispatched" ^ (req.Cohttp_lwt.Request.resource);
    wait
  in
  Lwt.async (start_server host port callback);
  let wait_for_client ?(pred=fun _->true) ~paths =
    print_endline @@ "wait for" ^ List.hd paths;
    ActionTable.wait table ~pred ~paths
  in
  let base_path = Uri.of_string base_url |> Uri.path in
  Lwt.return @@
    (fun () ->
      print_endline "accept!";
      let wait1, wake1 = Lwt.wait () in
      let wait2, wake2 = Lwt.wait () in
      return
        {Endpoint.handle={
           base_url;
           in_srv=(fun ?pred ~paths () ->
             wait_for_client ?pred ~base_path ~paths >>= fun (in_,outf,clsf) ->
             Lwt.wakeup wake1 outf;
             Lwt.wakeup wake2 clsf;
             return in_);
           out_srv=(fun t ->
             if Lwt.state wait1 = Sleep
             then failwith "write: no request"
             else wait1 >>= fun f ->
                  t >>= f)};
         close=(fun () ->
           if Lwt.state wait2 = Sleep
           then Lwt.fail (Failure "close: no request")
           else wait2 >>= fun f ->
                Lwt.return (f ()))}
    )


let http_parameter_contains (key,value) req =
  let uri = req |> Cohttp.Request.resource |> Uri.of_string in
  Uri.get_query_param uri key = Some value

let parse t =
  let open Lwt in
  t >>= fun (req, _body) ->
  let uri = req |> Cohttp.Request.resource |> Uri.of_string in
  Lwt.return Uri.(path uri, Uri.query uri)

let http_connector ~(base_url : string) () : cohttp_client Endpoint.connector =
  fun () ->
  let open Lwt in
  Resolver_lwt.resolve_uri ~uri:(Uri.of_string base_url) Resolver_lwt_unix.system >>= fun endp ->
  Conduit_lwt_unix.endp_to_client ~ctx:Conduit_lwt_unix.default_ctx endp >>= fun client ->
  Conduit_lwt_unix.connect ~ctx:Conduit_lwt_unix.default_ctx client >>= fun (_conn, ic, oc) ->
  let wait_input, wake_input = Lwt.wait () in
  let wait_close, wake_close = Lwt.wait () in
  return {Endpoint.handle={in_cli=begin
                             wait_input >>= fun r ->
                             print_endline @@ "in_cli, path:" ^ base_url;
                             Lwt.wakeup wake_close ();
                             return r
                           end;
                           out_cli=(fun ~path ~params ->
                             print_endline @@"out_cli, path:" ^path;
                             let uri = Uri.of_string (base_url ^ path) in
                             let uri = Uri.add_query_params uri params in
                             Cohttp_lwt_unix.Client.call `GET uri >>= fun (resp,body) ->
                             Cohttp_lwt.Body.to_string body >>= fun body ->
                             print_endline @@"got:" ^body;
                             Lwt.wakeup wake_input (resp, body);
                             return ()
                          )};
          close=(fun () ->
            print_endline "close func of http_connector";
            wait_close >>= fun () ->
            Lwt.catch (fun () ->
                Lwt_io.close ic >>= fun () ->
                Lwt_io.close oc
              ) (fun _exn -> return ()))}
