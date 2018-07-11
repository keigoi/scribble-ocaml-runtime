open Linocaml.Direct
open Scribble.Direct

module TwoBuyer = TwoBuyerAlt.Make(Scribble.Direct)

let book_ch = TwoBuyer.create_shmem_channel ()
let () =
  let module S = TwoBuyer.S in
  let module B = S.B.Raw in
  let module A = S.A.Raw in
  let _ : Thread.t =
    Thread.create
      (run (fun () ->
           return ())) ()
  in
  ()
