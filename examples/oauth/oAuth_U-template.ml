open Linocaml.Direct
open Scribble.Direct


let __dummy__ = failwith "Stub: Please remove __dummy__ in .ml file."

module OAuth_ =
  OAuth.Make
    (Scribble.Direct) (* or: Scribble_lwt *)
    (struct
      type page = unit
    end)

module C = OAuth_.U.C.Shmem
module P = OAuth_.U.P.Shmem

let __C_connector = OAuth_.U.C.Shmem.connector
let __P_connector = OAuth_.U.P.Shmem.connector


let main () =
  let%lin #o = OAuth_.U.initiate_U () in
  let%lin #o = connect __C_connector (C.role, C.oauth, __dummy__) in
  let%lin `_302_oauth_start(_, #o) = receive (C.role, C.receive_302_oauth_start) in
  let%lin #o = disconnect C.role in
  let%lin #o = connect __P_connector (P.role, P.authorize_request, __dummy__) in
  let%lin `_200(_, #o) = receive (P.role, P.receive_200) in
  let%lin #o = disconnect P.role in
  let%lin #o = connect __P_connector (P.role, P.submit, __dummy__) in
  begin match%lin receive (P.role, P.receive_302_success_or_302_fail) with
    | `_302_success(_, #o) ->
      let%lin #o = disconnect P.role in
      let%lin #o = connect __C_connector (C.role, C.callback_success, __dummy__) in
      let%lin `_200(_, #o) = receive (C.role, C.receive_200) in
      let%lin #o = disconnect C.role in
      close

    | `_302_fail(_, #o) ->
      let%lin #o = disconnect P.role in
      let%lin #o = connect __C_connector (C.role, C.callback_fail, __dummy__) in
      let%lin `_200(_, #o) = receive (C.role, C.receive_200) in
      close
  end


let () =  run main ()