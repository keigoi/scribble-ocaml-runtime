(* ocamlfind ocamlc -c -rectypes -thread -package session-ocaml,session-ocaml.ppx,session-ocaml.ppx_lens,ppx_deriving examples/multiparty_example.ml *)
open Multiparty
[%%s_syntax_rebind (module Multiparty.Syntax) ]   

(* declare a single slot 's' *)
type 'a ctx = <s : 'a>
[@@deriving lens]
[@@runner]
            
       
type p2
type p2_A = p2_A_1
and p2_A_1 = 
  [`connect of
    [`_1 of [`B] role * unit *
      [`disconnect of
        [`msg of [`B] role * unit *
          p2_A_1]]
    |`_2 of [`C] role * unit *
      [`disconnect of
        [`msg of [`C] role * unit *
          p2_A_1]]
    |`_3 of [`B] role * unit *
      [`disconnect of
        [`msg of [`B] role * unit *
          p2_A_1]]]]
type p2_B = p2_B_1
and p2_B_1 = 
  [`accept of
    [`_1 of [`A] role * unit *
      [`disconnect of
        [`msg of [`A] role * unit *
          p2_B_1]]
    |`_3 of [`A] role * unit *
      [`disconnect of
        [`msg of [`A] role * unit *
          p2_B_1]]]]
type p2_C = p2_C_1
and p2_C_1 = 
  [`accept of
    [`_2 of [`A] role * unit *
      [`disconnect of
        [`msg of [`A] role * unit *
          p2_C_1]]]]

let role_A : [`A] role = __mkrole "p2_A"
let role_B : [`B] role = __mkrole "p2_B"
let role_C : [`C] role = __mkrole "p2_C"

let msg__1 = {_pack=(fun a -> `_1(a))}
let msg__2 = {_pack=(fun a -> `_2(a))}
let msg__3 = {_pack=(fun a -> `_3(a))}
let msg_none = {_pack=(fun a -> `msg(a))}
   
let initiate_A : 'pre 'post. (p2,[`ConnectLater]) channel -> bindto:(empty,p2_A sess,'pre,'post) slot -> ('pre,'post,unit) monad = fun ch ~bindto ->
  Multiparty.__initiate ~myname:"p2_A" ch ~bindto

let initiate_B : 'pre 'post. (p2,[`ConnectLater]) channel -> bindto:(empty,p2_B sess,'pre,'post) slot -> ('pre,'post,unit) monad = fun ch ~bindto ->
  Multiparty.__initiate ~myname:"p2_B" ch ~bindto

let initiate_C : 'pre 'post. (p2,[`ConnectLater]) channel -> bindto:(empty,p2_C sess,'pre,'post) slot -> ('pre,'post,unit) monad = fun ch ~bindto ->
  Multiparty.__initiate ~myname:"p2_C" ch ~bindto

let ch = new_connect_later_channel ["p2_A";"p2_B";"p2_C"]

let proc_a () =
  let%slot #s = initiate_A ch in
  let rec loop () =
    if Random.int 2 <> 0 then begin
        connect s role_B msg__1 () >>
        disconnect s role_B msg_none () >>=
        loop
      end else if Random.int 2 <> 0 then begin
        connect s role_C msg__2 () >>
        disconnect s role_C msg_none () >>=
        loop
      end else begin
        connect s role_B msg__3 () >>
        disconnect s role_B msg_none () >>=
        loop
      end
  in
  loop ()

let proc_b () =
  let%slot #s = initiate_B ch in
  let rec loop () =
    match%label accept_receive s role_A with
    | `_1() -> begin
        disconnect s role_A msg_none () >>=
        loop
      end
    | `_3() -> begin
        disconnect s role_A msg_none () >>=
        loop
      end
  in
  loop ()

let proc_c () =
  let%slot #s = initiate_C ch in
  let rec loop () =
    match%label accept_receive s role_A with
    | `_2() -> begin
        disconnect s role_A msg_none () >>=
        loop
      end
  in
  loop ()


let () =
  ignore @@ Thread.create (run_ctx proc_b) ();
  ignore @@ Thread.create (run_ctx proc_c) ();
  run_ctx proc_a ()

