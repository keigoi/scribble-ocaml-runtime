open Multiparty

type 'a ctx = <s : 'a>
[@@deriving lens]
[@@runner]

open Travel1

let ch = new_channel_travel1 ()

let travel_c () =
  let%lin #s = initiate_C ch in
  connect s role_A msg_none () >>
  send s role_A msg_query "Heathrow, return" >>
  let%lin `quote(price,#s) = receive s role_A in
  if price > 50 then begin
      print_endline "reject";
      send s role_A msg_reject () >>
      close s
    end else begin
      print_endline "accpt";
      connect s role_S msg_none () >>
      send s role_S msg_pay "180 Queen's Gate London SW7 2AZ" >>
      let%lin `confirm(i,#s) = receive s role_S in
      send s role_A msg_accpt i >>
      close s
    end
  
let travel_a () =
  let%lin #s = initiate_A ch in
  let%lin `msg(_,#s) = accept s role_C in
    let rec loop () =
      match%lin receive s role_C with
      |`query(destination,#s) -> 
          send s role_C msg_quote (Random.int 50) >>=
          loop
      |`accpt(_,#s) -> close s
      |`reject(_,#s) -> (print_endline "rejected"; close s)
    in
    loop ()

let travel_s () =
  let%lin #s = initiate_S ch
  in
  let%lin `msg(_,#s) = accept s role_C
  in
  let%lin `pay(address_,#s) = receive s role_C
  in
  send s role_C msg_confirm 0 >>
  close s
    
let () =
  Random.self_init ();
  ignore @@ Thread.create (run_ctx travel_a) ();
  ignore @@ Thread.create (run_ctx travel_s) ();
  run_ctx travel_c ()
  
             
