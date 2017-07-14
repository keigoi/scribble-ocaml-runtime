open Multiparty
[%%s_syntax_rebind (module Multiparty.Syntax) ]   

type 'a ctx = <s : 'a>
[@@deriving lens]
[@@runner]

open Travel

type travel_S = travel_S_1
and travel_S_1 = 
  [`accept of
    [`msg of [`C] role * unit *
      [`recv of [`pay of [`C] role * str *
        [`send of
          [`confirm of [`C] role * int *
            [`close]]]]]]]

let ch = new_channel_travel ()

let travel_c () =
  let%slot #s = initiate_C ch in
  connect s role_A msg_none () >>
  send s role_A msg_query "Heathrow, return" >>
  match%label receive s role_A with `quote(price) -> begin
      if price > 50 then begin
          print_endline "reject";
          send s role_A msg_reject () >>
          close s
        end else begin
          print_endline "accpt";
          connect s role_S msg_none () >>
          send s role_S msg_pay "180 Queen's Gate London SW7 2AZ" >>
          match%label receive s role_S with `confirm(i) ->
          send s role_A msg_accpt i >>
          close s
        end
    end


let travel_a () =
  let%slot #s = initiate_A ch in
  match%label accept_receive s role_C with `msg() ->
    let rec loop () =
      begin match%label receive s role_C with
        |`query(destination) -> 
            send s role_C msg_quote (Random.int 50) >>=
            loop
        |`accpt(i) -> close s
        |`reject() -> (print_endline "rejected"; close s)
      end
    in
    loop ()

let travel_s () =
  let%slot #s = initiate_S ch in
  match%label accept_receive s role_C with
  | `msg() ->
     begin match%label receive s role_C with
     | `pay(address) ->
        send s role_C msg_confirm 0 >>
        close s
     end
    
let () =
  Random.self_init ();
  ignore @@ Thread.create (run_ctx travel_a) ();
  ignore @@ Thread.create (run_ctx travel_s) ();
  run_ctx travel_c ()
  
             
