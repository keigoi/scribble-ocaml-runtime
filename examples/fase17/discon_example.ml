open Multiparty
open P2

(* declare a single slot 's' *)
type 'a ctx = <s : 'a>
[@@deriving lens]
[@@runner]

let ch = new_channel_p2 ()

let proc_a () =
  let%slot #s = initiate_A ch in
  let rec loop () =
    if Random.int 2 <> 0 then begin
        connect s role_B msg_1 () >>
        disconnect s role_B msg_none () >>=
        loop
      end else begin
        connect s role_C msg_2 () >>
        disconnect s role_C msg_none () >>=
        loop
      end
  in
  loop ()

let proc_b () =
  let%slot #s = initiate_B ch in
  let rec loop () =
    match%lin accept s role_A with
    | `_1(_,#s) -> begin
        disconnect s role_A msg_none () >>=
        loop
      end
  in
  loop ()

let proc_c () =
  let%slot #s = initiate_C ch in
  let rec loop () =
    match%lin accept s role_A with
    | `_2(_,#s) -> begin
        disconnect s role_A msg_none () >>=
        loop
      end
  in
  loop ()

let () =
  ignore @@ Thread.create (fun _ -> run_ctx (proc_b ())) ();
  ignore @@ Thread.create (fun _ -> run_ctx (proc_c ())) ();
  run_ctx (proc_a ())
