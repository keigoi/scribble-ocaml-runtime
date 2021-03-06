module M = struct
  include Mutex
  type 'a io = 'a
end

module C = struct
  include Condition
  type 'a io = 'a
  type m = Mutex.t
end

include Session.Make(Linocaml.Direct)(M)(C)

module Shmem = Shmem.Make(Linocaml.Direct.IO)(Mutex)(Condition)(Endpoint)

type stream_ = {in_:in_channel; out:out_channel}

module Tcp : S.TCP with module Endpoint = Endpoint and type stream = stream_ = struct
  module Endpoint = Endpoint
  type stream = stream_  = {in_:in_channel; out:out_channel}
  type _ Endpoint.conn_kind += Stream : stream Endpoint.conn_kind

  let make (fi, fo) =
    let c = {in_=Unix.in_channel_of_descr fi; out=Unix.out_channel_of_descr fo} in
    {Endpoint.handle=c; close=(fun _ -> close_in c.in_)}

  let connector ~host ~port : stream Endpoint.connector =
      fun () ->
      match Unix.getaddrinfo host (string_of_int port) [] with
      | [] -> failwith ("Host not found " ^ host)
      | h::_ ->
         let ic,oc = Unix.open_connection h.Unix.ai_addr in
         {Endpoint.handle={in_=ic; out=oc}; close=(fun _ -> close_in ic)}

  let new_domain_channel () =
    let path = Filename.temp_file "sock" "sock" in
    Unix.unlink path;
    let sock_listen = Unix.(socket PF_UNIX SOCK_STREAM 0) in
    Unix.(bind sock_listen (ADDR_UNIX path));
    Unix.listen sock_listen 0;
    (fun () ->
        let sock_cli = Unix.(socket PF_UNIX SOCK_STREAM 0) in
        Unix.(connect sock_cli (ADDR_UNIX path));
        make (sock_cli, sock_cli)),
    (fun () ->
        let sock_serv, _ = Unix.(accept sock_listen) in
        make (sock_serv, sock_serv))
end
