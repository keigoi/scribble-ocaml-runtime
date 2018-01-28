open Linocaml.Direct
open Scribble.Direct


let __dummy__ = failwith "Stub: Please remove __dummy__ in .ml file."

module OAuth_ =
  OAuth.Make
    (Scribble.Direct) (* or: Scribble_lwt *)
    (struct
      type page = unit
    end)

module U = OAuth_.P.U.Shmem
module C = OAuth_.P.C.Shmem


let __C_acceptor = OAuth_.P.C.Shmem.acceptor
let __U_acceptor = OAuth_.P.U.Shmem.acceptor

let main () =
  let%lin #o = OAuth_.P.initiate_P () in
  let%lin `authorize_request(_, #o) = accept __U_acceptor (U.role, U.receive_authorize_request) in
  let%lin #o = send (U.role, U._200, __dummy__) in
  let%lin #o = disconnect U.role in
  let%lin `submit(_, #o) = accept __U_acceptor (U.role, U.receive_submit) in
  begin if __dummy__ then
    let%lin #o = send (U.role, U._302_success, __dummy__) in
    let%lin #o = disconnect U.role in
    let%lin `access_token(_, #o) = accept __C_acceptor (C.role, C.receive_access_token) in
    let%lin #o = send (C.role, C._200, __dummy__) in
    let%lin #o = disconnect C.role in
    close
  else
    let%lin #o = send (U.role, U._302_fail, __dummy__) in
    let%lin #o = disconnect U.role in
    close
  end


let () =  run main ()