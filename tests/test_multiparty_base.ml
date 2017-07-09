open OUnit
open Multiparty_base
   
let fork (x : 'a) (f : 'a -> unit) : unit = ignore (Thread.create f x)

             
let test_uchan () =
  let c = UChan.create () in
  
  fork () (fun () -> UChan.send c "abc");
  assert_equal (UChan.receive c)  ("abc");
  
  fork () (fun () -> UChan.send c (`A("abc")));
  assert_equal (UChan.receive c)  (`A("abc"));
  (* assert_bool "" (UChan.receive c = (`B("abc"))); *)
  ()

let test_mchan () =
  print_endline "test_mchan";
  
  let shared = MChan.create () in
  
  let cli (myname,hername,first) =
    print_endline (myname ^ " started.");
    let mc = MChan.connect shared ~myname in
    let srv = MChan.get_connection mc "srv"
    and her = MChan.get_connection mc hername
    in
    if first then begin
        UChan.send her (myname ^ " to " ^ hername);
        print_endline ("sent to " ^ hername);
        assert_equal (UChan.receive her) (hername ^ " to " ^ myname);
        print_endline ("received from " ^ hername)
      end
    else
      begin
        assert_equal (UChan.receive her) (hername ^ " to " ^ myname);
        print_endline ("received from " ^ hername);
        UChan.send her (myname ^ " to " ^ hername);
        print_endline ("sent to " ^ hername)
      end;
    assert_equal (UChan.receive srv) ("server to " ^ myname);
    UChan.send srv (myname ^ " to server");
    print_endline (myname ^ ": received and sent to the server");
    print_endline (myname ^ " finished");
    ()
  in
  fork ("cli1","cli2",true) cli;
  fork ("cli2","cli1",false) cli;
  let mymap = MChan.accept ~myname:"srv" ~cli_count:2 shared in
  let cli1 = MChan.get_connection mymap "cli1"
  and cli2 = MChan.get_connection mymap "cli2"
  in
  UChan.send cli1 ("server to cli1");
  UChan.send cli2 ("server to cli2");
  print_endline "sent to clients";
  assert_equal (UChan.receive cli1) ("cli1 to server");
  assert_equal (UChan.receive cli2) ("cli2 to server");
  print_endline "done.";
  ()

let suite =
  "Test uchan" >:::
    ["test_uchan" >:: test_uchan;
     "test_mchan" >:: test_mchan;
    ]

let _ =
  run_test_tt_main suite

