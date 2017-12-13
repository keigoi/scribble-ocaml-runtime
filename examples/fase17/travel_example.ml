open Scribble.Direct
open Linocaml.Direct

type 'a ctx = <s : 'a>
[@@deriving lens]
[@@runner]

open Travel1

(* FIXME: different participant may have different connection types for a role *)
let role_A = mk_role_A ConnKind.Shmem
let role_C = mk_role_C ConnKind.Shmem
let role_S = mk_role_S ConnKind.Shmem

let travel_c ~conn_A ~conn_S () =
  let%lin #s = initiate_C () in
  let%lin #s = connect s conn_A role_A msg_none () in
  let%lin #s = send s role_A msg_query "Heathrow, return" in
  let%lin `quote(price,#s) = receive s role_A in
  if price > 50 then begin
      print_endline "reject";
      let%lin #s = send s role_A msg_reject () in
      close s
    end else begin
      print_endline "accpt";
      let%lin #s = connect s conn_S role_S msg_none () in
      let%lin #s = send s role_S msg_pay "180 Queen's Gate London SW7 2AZ" in
      let%lin `confirm(i,#s) = receive s role_S in
      let%lin #s = send s role_A msg_accpt i in
      close s
    end

let travel_a me =
  let%lin #s = initiate_A () in
  let%lin `msg(_,#s) = accept s me role_C in
    let rec loop () =
      match%lin receive s role_C with
      |`query(destination,#s) ->
          let%lin #s = send s role_C msg_quote (Random.int 100) in
          loop ()
      |`accpt(_,#s) -> close s
      |`reject(_,#s) -> (print_endline "rejected"; close s)
    in
    loop ()

let travel_s me =
  let%lin #s = initiate_S ()
  in
  let%lin `msg(_,#s) = accept s me role_C
  in
  let%lin `pay(address_,#s) = receive s role_C
  in
  let%lin #s = send s role_C msg_confirm 0 in
  close s

let () =
  Random.self_init ();
  let acpt_A, conn_A = shmem ()
  and acpt_S, conn_S = shmem ()
  in
  ignore @@ Thread.create (run_ctx travel_a) acpt_A;
  ignore @@ Thread.create (run_ctx travel_s) acpt_S;
  run_ctx (travel_c ~conn_A ~conn_S) ()
