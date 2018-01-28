open Linocaml.Direct
open Scribble.Direct


let __dummy__ = failwith "Stub: Please remove __dummy__ in .ml file."

module OAuth_ =
  OAuth.Make
    (Scribble.Direct) (* or: Scribble_lwt *)
    (struct
      type page = unit
    end)

module U = OAuth_.C.U.Shmem
module P = OAuth_.C.P.Shmem

let __P_connector = OAuth_.C.P.Shmem.connector
let __U_acceptor = OAuth_.C.U.Shmem.acceptor

let main () =
  let%lin #o = OAuth_.C.initiate_C () in
  let%lin `oauth(_, #o) = accept __U_acceptor (U.role, U.receive_oauth) in
  let%lin #o = send (U.role, U._302_oauth_start, __dummy__) in
  let%lin #o = disconnect U.role in
  begin match%lin accept __U_acceptor (U.role, U.receive_callback_success_or_callback_fail) with
    | `callback_success(_, #o) ->
      let%lin #o = connect __P_connector (P.role, P.access_token, __dummy__) in
      let%lin `_200(_, #o) = receive (P.role, P.receive_200) in
      let%lin #o = disconnect P.role in
      let%lin #o = send (U.role, U._200, __dummy__) in
      let%lin #o = disconnect U.role in
      close

    | `callback_fail(_, #o) ->
      let%lin #o = send (U.role, U._200, __dummy__) in
      close
  end


let () =  run main ()