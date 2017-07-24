open Multiparty
    
(* declare a single slot 's' *)
type 'a ctx = <s : 'a>
[@@deriving lens]
[@@runner]
            
let ch = new_channel ()

open Travel

let booking_agent () =
  (* bind an agent's session to the slot s *)
  let%lin #s = connect_A ch in

  let rec loop state () =
    match%lin receive s role_C with
    | `Query((query:string data),#s) -> begin
        
        let quote = 70 in
        send s role_C msg_Quote quote >>
        send s role_S msg_Dummy () >>=
        loop (Some (query,quote))
      end
    | `Yes(_,#s) -> send s role_S msg_Yes ()
    | `No(_,#s) -> send s role_S msg_No ()
  in
  loop None ()
  >>
  let%lin `Bye(_,#s) = receive s role_C in 
  close s

let booking_client () =
  let%lin #s = accept_C ch in
  
  send s role_A msg_Query "from London to Paris, 10th July 2017" >>

  let%lin `Quote(price,#s) = receive s role_A in
  (Printf.printf "client: price received: %d" price; return ()) >>

  begin
    if price < 100 then
      begin
        send s role_A msg_Yes () >>
        send s role_S msg_Payment "123-4567, Nishi-ku, Nagoya, Japan" >>

        let%lin `Ack(_,#s) = receive s role_S in
        return ()
      end
    else begin
      send s role_A msg_No ()
    end
  end >>
  send s role_A msg_Bye () >>
  close s
      

let booking_server () =
  let%lin #s = connect_S ch in

  let rec loop () =
    match%lin receive s role_A with
    | `Dummy(_,#s) -> loop ()
    | `Yes(_,#s) -> begin
        let%lin `Payment(address,#s) = receive s role_C in
         send s role_C msg_Ack ()
      end
    | `No(_,#s) -> return ()
  in
  loop () >>
  close s

let fork name f () =
  Thread.create (fun () -> print_endline (name ^ ": started."); f (); print_endline (name ^ ": finished.")) ()
  
let _ =
  let t1 = fork "client" (run_ctx booking_client) () in
  let t2 = fork "agent" (run_ctx booking_agent) () in
  print_endline "server started.";
  run_ctx booking_server ();
  print_endline "server finished.";
  Thread.join t1;
  Thread.join t2;
  ()
