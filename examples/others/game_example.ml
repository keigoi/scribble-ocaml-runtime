open Multiparty
open Game2Proto
open Game

type ('a,'b,'c,'d,'e) ctx = <t1 : 'a; t2: 'b; t3: 'c; s: 'd; t: 'e>
[@@deriving lens]
[@@runner]            

let ch = new_channel ()
let gamech = new_lazy_channel ()
   
let server () =
  let%slot #t1 = accept_A gamech in
  let%slot #t2 = connect_B gamech in
  let%slot #t3 = connect_C gamech in
  
  let%slot #s = accept_S ch in
  deleg_send s role_C msg_playAsA t1 >>
  close s >>
    
  let%slot #s = accept_S ch in
  deleg_send s role_C msg_playAsB t2 >>
  close s >>
    
  let%slot #s = accept_S ch in
  deleg_send s role_C msg_playAsC t3 >>
  close s


let rec playAsA () =
  if Random.int 2 <> 0 then begin
      send t role_B msg_1 () >>
      match%lin receive t role_C with
      | `_1(_,#t) -> playAsA ()
    end else begin
      send t role_B msg_2 () >>
      match%lin receive t role_C with
      | `_2(_,#t) -> close t
    end

let rec playAsB () =
  match%lin receive t role_A with
  | `_1(_,#t) -> send t role_C msg_1 () >> playAsB ()
  | `_2(_,#t) -> send t role_C msg_2 () >> close t

let rec playAsC () =
  match%lin receive t role_B with
  | `_1(_,#t) -> send t role_A msg_1 () >> playAsC ()
  | `_2(_,#t) -> send t role_A msg_2 () >> close t
       
let client () =
  let%slot #s = Game2Proto.connect_C ch in
  begin match%lin receive s role_S with
  | `playAsA(#t,#s) -> close s >> playAsA ()
  | `playAsB(#t,#s) -> close s >> playAsB ()
  | `playAsC(#t,#s) -> close s >> playAsC ()
  end


let () =
  Random.self_init ();
  let t1 = Thread.create (fun () -> run_ctx (client ())) () in
  let t2 = Thread.create (fun () -> run_ctx (client ())) () in
  let t3 = Thread.create (fun () -> run_ctx (client ())) () in
  run_ctx (server ());
  Thread.join t1;
  Thread.join t2;
  Thread.join t3;
  ()
