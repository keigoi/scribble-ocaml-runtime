open Linocaml.Direct
open Scribble.Direct

module TravelAgency = TravelAgency.Make(Scribble.Direct)

let book_ch = TravelAgency.create_shmem_channel ()

let () =
  let module S = TravelAgency.S in
  let module C = S.C.Raw in
  let module A = S.A.Raw in
  let _ : Thread.t =
    Thread.create
      (run (fun () ->
           S.initiate_shmem book_ch >>= fun%lin #o ->
           let rec loop () =
             match%lin receive (A.role, A.receive_info_or_aCCEPT_or_rEJECT) with
             | `info(info, #o) ->
                Printf.printf "server: received a piece of information from Agency: %s\n" info;
                loop ()
             | `ACCEPT(_, #o) ->
                Printf.printf "server: received ACCEPT from Agency\n";
                receive (C.role, C.receive_address) >>= fun%lin (`Address(address, #o)) ->
                Printf.printf "server: received Client address: %s\n" address;
                send (C.role, C.msg, "Transaction copmleted.") >>= fun%lin #o ->
                close
             | `REJECT(info, #o) ->
                close
           in
           loop () >>
           (Printf.printf "server: finished.\n";
           return ())

      )) ()
  in
  ()

let () =
  let module A = TravelAgency.A in
  let module C = A.C.Raw in
  let module S = A.S.Raw in
  let _ : Thread.t =
    Thread.create
      (run (fun () ->
           A.initiate_shmem book_ch >>= fun%lin #o ->
           let rec loop () =
             match%lin receive (C.role, C.receive_query_or_aCCEPT_or_rEJECT) with
             | `query(info, #o) ->
                Printf.printf "agency: received a query from Client: %s\n" info;
                let price = 100 in
                send (C.role, C.price, price) >>= fun%lin #o ->
                Printf.printf "agency: replied with the price of %d\n" price;
                let info = "CLIENT QUERY:" ^ info in
                send (S.role, S.info, info) >>= fun%lin #o ->
                Printf.printf "agency: sent a query information to Server: %s\n" info;
                loop ()
             | `ACCEPT(_, #o) ->
                send (S.role, S.aCCEPT, ()) >>= fun%lin #o ->
                close
             | `REJECT(_, #o) ->
                send (S.role, S.rEJECT, ()) >>= fun%lin #o ->
                close
           in
           loop ())) ()
  in
  ()

let () =
  let module C = TravelAgency.C in
  let module S = C.S.Raw in
  let module A = C.A.Raw in
  run (fun () ->
      C.initiate_shmem book_ch >>= fun%lin #o ->
      Printf.printf "client: sending an query\n";
      send (A.role, A.query, "from London to Paris, 10th Sep 2018") >>= fun%lin #o ->
      receive (A.role, A.receive_price) >>= fun%lin (`price(p, #o)) ->
      Printf.printf "client: price %d received from Agency\n" p;
      Printf.printf "client: proceeding with ACCEPT\n";
      send (A.role, A.aCCEPT, ()) >>= fun%lin #o ->
      Printf.printf "client: sending an receipt address to Server\n";
      send (S.role, S.address, "111-222, West St. Nagoya, Japan") >>= fun%lin #o ->
      receive (S.role, S.receive_msg) >>= fun%lin (`msg(message, #o)) ->
      Printf.printf "client: received message from Server \"%s\"\n" message;
      close)
   ()
