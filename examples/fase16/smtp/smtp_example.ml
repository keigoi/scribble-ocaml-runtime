open Linocaml.Direct
open Scribble.Direct

module Smtp = Smtp.Make(Scribble.Direct)

let smtp_ch = Smtp.create_shmem_channel ()

module C = Smtp.C
module S = C.S.Raw(Scribble.Direct.Raw)

type 'a t = <s:'a> [@@deriving lens][@@runner]

let _ =
    C.initiate_C () >>= fun%lin #s ->
    return ()
