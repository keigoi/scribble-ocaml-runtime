open Multiparty
open P2

(* declare a single slot 's' *)
type 'a ctx = <s : 'a>
[@@deriving lens]
[@@runner]

let ch = new_channel_p2 ()

let proc_a () =
  let%lin #s = initiate_A ch in
  let rec loop () =
    if Random.int 2 <> 0 then begin
        connect s role_B msg_1 () >>
        disconnect s role_B msg_none () >>
        loop ()
      end else begin
        connect s role_C msg_2 () >>
        disconnect s role_C msg_none () >>
        loop ()
      end
  in
  loop ()

let proc_b () =
  let%lin #s = initiate_B ch in
  let rec loop () =
    let%lin `_1(_,#s) = accept s role_A in
    disconnect s role_A msg_none () >>=
    loop
  in
  loop ()

let proc_c () =
  let%lin #s = initiate_C ch in
  let rec loop () =
    let%lin `_2(_,#s) = accept s role_A in
    disconnect s role_A msg_none () >>=
    loop
  in
  loop ()

let () =
  ignore @@ Thread.create (run_ctx proc_b) ();
  ignore @@ Thread.create (run_ctx proc_c) ();
  run_ctx proc_a ()
