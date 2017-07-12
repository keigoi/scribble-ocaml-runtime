(* ocamlfind ocamlc -c -rectypes -thread -package session-ocaml,session-ocaml.ppx,session-ocaml.ppx_lens,ppx_deriving examples/multiparty_example.ml *)
open Multiparty
[%%s_syntax_rebind (module Multiparty.Syntax) ]   

type 'a ctx = <s : 'a>
[@@deriving lens]
[@@runner]
            
let ch = new_channel ()

open Booking

let booking_agent () =

  let rec loop state () =
    match%branch s role_C with
    | `Query((query:string)) -> begin
        
        let quote = 70 in
        send s role_C msg_Quote quote >>
        send s role_S msg_Dummy () >>=
        loop (Some (query,quote))
      end
    | `Yes() -> send s role_S msg_Yes ()
    | `No() -> send s role_S msg_No ()
  in
  loop None ()
  >>
  match%branch s role_C with `Bye() ->
  close s

let booking_client () =
  send s role_A msg_Query "from London to Paris, 10th July 2017" >>
  
  match%branch s role_A with `Quote(price) ->
  (Printf.printf "client: price received: %d" price; return ()) >>

  begin
    if price < 100 then
      begin
        send s role_A msg_Yes () >>
        send s role_S msg_Payment "123-4567, Nishi-ku, Nagoya, Japan" >>
        match%branch s role_S with (`Ack()) ->
        return ()
      end
    else begin
      send s role_A msg_No ()
    end
  end >>
  send s role_A msg_Bye () >>
  close s
      

let booking_server () =

  let rec loop () =
    match%branch s role_A with
    | `Dummy() -> loop ()
    | `Yes() -> begin
        match%branch s role_C with
        | `Payment(address) ->
           send s role_C msg_Ack ()
      end
    | `No() -> return ()
  in
  loop () >>
  close s

let fork name f () =
  Thread.create (fun () -> print_endline (name ^ ": started."); f (); print_endline (name ^ ": finished.")) ()
  
let _ =
  let t1 = fork "client" (
      run_ctx begin fun () ->
          let%slot #s = connect_C ch in
          booking_client ()
        end) () in
  let t2 = fork "agent" (
      run_ctx begin fun () ->
          let%slot #s = connect_A ch in
          booking_agent ()
        end) () in
  print_endline "server started.";
  run_ctx begin fun () ->
      let%slot #s = accept_S ch in
      booking_server ()
    end ();
  print_endline "server finished.";
  Thread.join t1;
  Thread.join t2;
  ()
  
