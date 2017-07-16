let obj_conv_msg : 'a -> 'p -> 'b = fun poly sess ->
  let poly = Obj.dup (Obj.repr poly) in
  if Obj.size poly <> 2 then
    failwith (Printf.sprintf "unexpected variant size: %d" (Obj.size poly))
  else
    let old_payload = Obj.field poly 1 in
    if Obj.size old_payload <> 3 then
      failwith (Printf.sprintf "unexpected variant content size: %d" (Obj.size old_payload))
    else begin
        let msg = Obj.field old_payload 1 (* (_,msg,_) *) in
        let new_payload = Obj.repr (msg,sess) in
        Obj.set_field poly 1 new_payload;
        Obj.obj poly
      end

let p : [`A of int * int] = obj_conv_msg (`A(1,2,3)) 4;;
  
  match p with
    `A(x,y) -> Printf.printf "%d,%d\n" x y;;
    
