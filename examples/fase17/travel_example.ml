open Multiparty

type 'a ctx = <s : 'a>
[@@deriving lens]
[@@runner]

open Travel1

let ch = new_channel_travel1 ()

let travel_c () =
  let%slot #s = initiate_C ch in
  connect s role_A msg_none () >>
  send s role_A msg_query "Heathrow, return" >>
  match%lin receive s role_A with `quote(price,#s) -> begin
      if price > 50 then begin
          print_endline "reject";
          send s role_A msg_reject () >>
          close s
        end else begin
          print_endline "accpt";
          connect s role_S msg_none () >>
          send s role_S msg_pay "180 Queen's Gate London SW7 2AZ" >>
          match%lin receive s role_S with `confirm(i,#s) ->
          send s role_A msg_accpt i >>
          close s
        end
    end


let travel_a () =
  let%slot #s = initiate_A ch in
  match%lin accept s role_C with `msg(_,#s) ->
    let rec loop () =
      begin match%lin receive s role_C with
        |`query(destination,#s) -> 
            send s role_C msg_quote (Random.int 50) >>=
            loop
        |`accpt(_,#s) -> close s
        |`reject(_,#s) -> (print_endline "rejected"; close s)
      end
    in
    loop ()

let travel_s () =
  let%slot #s = initiate_S ch in
  match%lin accept s role_C with
  | `msg(_,#s) ->
     begin match%lin receive s role_C with
     | `pay(address_,#s) ->
        send s role_C msg_confirm 0 >>
        close s
     end
    
let () =
  Random.self_init ();
  ignore @@ Thread.create (fun _ -> run_ctx (travel_a ())) ();
  ignore @@ Thread.create (fun _ -> run_ctx (travel_s ())) ();
  run_ctx (travel_c ())
  
             
