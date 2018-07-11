open Linocaml.Direct
open Scribble.Direct

module Adder = Adder.Make(Scribble.Direct)

let adder_ch = Adder.create_shmem_channel ()

let () =
  let module S = Adder.S in
  let module C = S.C.Raw in
  let _ : Thread.t =
    Thread.create
      (run (fun () ->
           S.initiate_shmem adder_ch >>= fun%lin #o ->
           let rec loop () =
             match%lin receive (C.role, C.receive_add_or_bye) with
             | `Add(pair, #o) ->
                let i, j = pair in
                send (C.role, C.res, i+j) >>= fun%lin #o ->
                loop ()
             | `Bye(_, #o) ->
                send (C.role, C.bye, ()) >>= fun%lin #o ->
                close
           in
           loop ())) ()
  in
  ()

let () =
  let module C = Adder.C in
  let module S = C.S.Raw in
  run (fun () ->
    C.initiate_shmem adder_ch >>= fun%lin #o ->
    send    (S.role, S.add, (100,200))  >>= fun%lin #o ->
    receive (S.role, S.receive_res) >>= fun%lin (`Res(ans, #o)) ->
    Printf.printf "ans:%d\n" ans;

    send    (S.role, S.bye, ()) >>= fun%lin #o ->
    receive (S.role, S.receive_bye) >>= fun%lin (`Bye(_, #o)) ->
    close >>
    return ())
   ()
