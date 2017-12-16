module Chan = Scribble.Channel.Make
                (Linocaml_lwt.IO)
                (struct
                  type +'a io = 'a Lwt.t
                  include Lwt_mutex
                end)
                (struct
                  type +'a io = 'a Lwt.t
                  type m = Lwt_mutex.t
                  type t = unit Lwt_condition.t
                  let create = Lwt_condition.create
                  let signal c = Lwt_condition.signal c ()
                  let wait c m = Lwt_condition.wait ~mutex:m c
                end)
module RawChan = Scribble.Unsafe.Make_raw_dchan(Scribble.Dchannel.Make(Chan))

include Scribble.Session.Make
          (Linocaml_lwt)
          (Chan)
          (RawChan)

type stream_ = {in_:Lwt_io.input_channel; out:Lwt_io.output_channel}

module Tcp : Scribble.Base.TCP with module Endpoint = Endpoint and type stream = stream_
  = struct
  module Endpoint = Endpoint

  type stream = stream_  = {in_:Lwt_io.input_channel; out:Lwt_io.output_channel}
  type _ Endpoint.conn_kind += Stream : stream Endpoint.conn_kind

  open Lwt

  let make (fi, fo) =
    let open Lwt_io in
    let c = {in_=of_fd Input fi; out=of_fd Output fo} in
    {Endpoint.handle=c; close=(fun _ -> close c.in_)}

  let connector ~host ~port : stream Endpoint.connector =
    fun () ->
    Lwt_unix.getaddrinfo host (string_of_int port) [] >>= function
    | [] -> failwith ("Host not found " ^ host)
    | h::_ ->
       Lwt_io.open_connection h.Unix.ai_addr >>= fun (ic,oc) ->
       Lwt.return {Endpoint.handle={in_=ic; out=oc}; close=(fun _ -> Lwt_io.close ic)}

  let new_domain_channel () =
    let open Lwt_unix in
    let path = Filename.temp_file "sock" "sock" in
    unlink path >>= fun () ->
    let sock_listen = socket PF_UNIX SOCK_STREAM 0 in
    bind sock_listen (ADDR_UNIX path) >>= fun () ->
    listen sock_listen 0;
    Lwt.return @@
      ((fun () ->
        let sock_cli = socket PF_UNIX SOCK_STREAM 0 in
        connect sock_cli (ADDR_UNIX path) >>= fun () ->
        Lwt.return @@ make (sock_cli, sock_cli)),
       (fun () ->
         accept sock_listen >>= fun (sock_serv, _) ->
         return @@ make (sock_serv, sock_serv)))
end

let shmem () =
  let handle = RawChan.create () in
  (fun () -> {Endpoint.handle; close=(fun _ -> Lwt.return ())}),
  (fun () -> {Endpoint.handle=RawChan.reverse handle; close=(fun _ -> Lwt.return ())})
