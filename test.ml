
let race_check = 
  let mutex = Mutex.create () in
  fun () ->
    if not (Mutex.try_lock mutex) then begin
      failwith "race detected!"
    end;
    Thread.delay 0.001;
    Mutex.unlock mutex



(* Test for channels *)
module C = Channel;;

(* send n to 1 of type int on channel c *)
let sender c put_ n = 
  let put_ = put_ () in
  let ok = ref false in
  ignore (Thread.create (fun _ ->
    Thread.delay 0.001;
    print_string "s "; flush stderr;
    for i=n downto 1 do
      Thread.yield ();
      put_ c i
    done;
    ok := true) ());
    ok

(* receive and sum all ints until finish () = true *)
let receiver c finish get_ () = 
  let get_ = get_ () in
  let ok = ref None in
  ignore (Thread.create (fun _ ->
    Thread.delay 0.001;
    print_string "r "; flush stderr;
    let sum = ref 0 in
    let rec loop () =
      Thread.yield (); (* explicit yield is needed since OCaml's thread lacks fairness on this case *)
      sum := get_ c + !sum;      
      if not (finish ()) || not (C.is_empty c) then 
        loop () 
      else 
        ok := Some (!sum)
    in loop ()) ());
  ok

let rec loop n f x =
  match n with
  | 0 -> []
  | n -> f x :: loop (n-1) f x

let test_chan put_ get_ =
  let c = C.create () in
  let amount = 1000 and threads = 100 
  in
  (* start sender threads *)
  let senders = loop threads (sender c put_) amount in
  let senders_finished () = List.for_all (fun c -> !c) senders 
  in
  (* start receiver threads *)
  let receivers = loop threads (receiver c senders_finished get_) () in
  let receivers_finished () = List.for_all (fun c -> !c<>None) receivers 
  in
  (* wait until all receives finishes *)
  while not (receivers_finished ()) do
    Thread.delay 0.;
  done;
  let get x = 
    match !x with 
    | None -> failwith "impossible" 
    | Some v -> print_string (string_of_int v^" "); v 
  in
  (* sum all received values *)
  let sum = List.fold_left (fun x r -> x + (get r)) 0 receivers in
  (* check it *)
  print_endline (string_of_int sum);
  assert ((amount*(amount+1))/2 * threads = sum)


let _ = 
  let cnt = 100000 in
  let c = C.create () in
  for i=0 to cnt-1 do
    ignore (Thread.create (fun _ -> Thread.delay 0.001; C.send c (Random.bits ())) ());
    let v = C.peek c and w = C.receive c in
    assert (v = w)
  done;
  print_endline "Channel.peek/receive OK.";
  for i=0 to cnt-1 do
    let len = Random.bits () mod 100 + 1 in
    for n=0 to len-1 do
      C.send c n;
    done;
    assert (C.length c = len);
    assert (not (C.is_empty c));
    C.clear c;
    assert (C.is_empty c);
  done;
  print_endline "Channel.length/is_empty OK.";
  ()

let _ = 
  let receive_all () c = C.receive_all c (+) 0
  and try_receive () c = 
    match C.try_receive c with
    | None -> 0
    | Some v -> v
  and receive_all_ () = 
    let buf = ref 0 in
    fun c ->
      C.receive_all_ c (fun n -> buf := n + !buf);
      let v = !buf in
      buf := 0;
      v
  and send () c n = C.send c n
  and send_all () = 
    let buf = ref [] in
    fun c n ->
      buf := n :: !buf;
      if List.length !buf=10 || n = 1 then begin
        C.send_all c (List.rev !buf);
        buf := []
      end
  in
  test_chan send receive_all;
  print_endline "Channel.send/receive_all OK.";
  test_chan send_all receive_all;
  print_endline "Channel.send/receive_all OK.";
  test_chan send receive_all_;
  print_endline "Channel.send/receive_all_ OK.";
  test_chan send_all receive_all_;
  print_endline "Channel.send/receive_all_ OK.";
  test_chan send try_receive;
  print_endline "Channel.send/try_receive OK.";
  test_chan send_all try_receive;
  print_endline "Channel.send/try_receive OK.";
  ()
