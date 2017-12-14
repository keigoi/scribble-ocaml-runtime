open Scribble.Direct
open Linocaml.Direct

type 'a ctx = <s : 'a>
[@@deriving lens]
[@@runner]

module MyParsersAndPrinters = struct
  let escape = String.escaped
  let unescape s = Scanf.sscanf ("\"" ^ s ^ "\"") "%S" (fun u -> u)

  let output_line out str = output_string out (escape str^"\n"); flush out
  let input_line in_ = unescape @@ input_line in_

  module Senders = struct
    include Senders
    open Tcp

    let _reject_msg_query {out} :
          [`reject of _ | `msg of _ | `query of _] -> unit =
      function
      | `reject (_,_,_) -> output_line out "reject"
      | `msg (_,_,_) -> output_line out "msg"
      | `query (_,Linocaml.Base.Data_Internal__ qstr,_) ->
         output_line out "query";
         output_line out qstr

    let _quote {out} : [`quote of _] -> unit = function
      | `quote(_,Linocaml.Base.Data_Internal__ price, _) ->
         output_line out "quote";
         output_line out (string_of_int price)

    let _pay {out} : [`pay of _] -> unit = function
      | `pay(_,Linocaml.Base.Data_Internal__ addr, _) ->
         output_line out "pay";
         output_line out addr

    let _confirm {out} : [`confirm of _] -> unit = function
      | `confirm(_,Linocaml.Base.Data_Internal__ id,_) ->
         output_line out "confirm";
         output_line out (string_of_int id)
  end
  module Receivers = struct
    include Receivers
    open Tcp
    let _confirm {in_} : [`confirm of _] =
      match input_line in_ with
      | "confirm" ->
         let id = int_of_string (input_line in_) in
         `confirm(Linocaml.Base.Data_Internal__ id, Obj.magic ())
      | str -> failwith ("unknown token:"^ str)

    let _msg {in_} : [`msg of _] =
      print_endline "_msg called";
      match input_line in_ with
      | "msg" ->
         `msg(Linocaml.Base.Data_Internal__ (), Obj.magic ())
      | str -> failwith ("unknown token:"^ str)

    let _pay {in_} : [`pay of _] =
      let line1 = input_line in_ in
      let line2 = input_line in_ in
      match line1, line2 with
      | "pay", str -> `pay(Linocaml.Base.Data_Internal__ str, Obj.magic ())
      | _ -> failwith ("unknown token:" ^line1)
  end
end
open MyParsersAndPrinters

open Travel1

let travel_c ~conn_A ~conn_S () =
  let role_A = mk_role_A Shmem
  and role_S = mk_role_S Tcp.Stream
  in
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
  let role_C = mk_role_C Shmem
  in
  let%lin #s = initiate_A () in
  let%lin `msg(_,#s) = accept s me role_C in
    let rec loop () =
      match%lin receive s role_C with
      |`query(destination,#s) ->
        print_endline ("destination:" ^destination);
        let%lin #s = send s role_C msg_quote (Random.int 100) in
        loop ()
      |`accpt(_,#s) -> close s
      |`reject(_,#s) -> (print_endline "rejected"; close s)
    in
    loop ()

let travel_s me =
  let role_C = mk_role_C Tcp.Stream
  in
  let%lin #s = initiate_S () in
  let%lin `msg(_,#s) = accept s me role_C in
  let%lin `pay(address_,#s) = receive s role_C in
  let%lin #s = send s role_C msg_confirm 0 in
  close s

let () =
  Random.self_init ();
  let acpt_A, conn_A = shmem ()
  and acpt_S, conn_S = Tcp.new_domain_channel ()
  in
  ignore @@ Thread.create (run_ctx travel_a) acpt_A;
  ignore @@ Thread.create (run_ctx travel_s) acpt_S;
  run_ctx (travel_c ~conn_A ~conn_S) ()
