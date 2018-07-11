
(* unsafe: fun (`tag(p)) -> p *)
let get_payload : Obj.t -> Obj.t = fun var ->
  if Obj.size var <> 2 then
    failwith (Printf.sprintf "get_payload: unexpected variant size: %d (expected: 2)" (Obj.size var))
  else
    Obj.field var 1

(* unsafe: fun (`tag(p1)) p2 -> `tag(p2) *)
let replace_payload : Obj.t -> Obj.t -> Obj.t = fun var new_payload ->
  let var = Obj.dup var in
  if Obj.size var <> 2 then
    failwith (Printf.sprintf "replace_payload: unexpected variant size: %d (expected: 2)" (Obj.size var))
  else begin
      Obj.set_field var 1 new_payload;
      var
    end

(* unsafe: fun (`tag(role,msg,sess)) -> `tag(msg,sess) *)
let remove_role_part : Obj.t -> Obj.t = fun var ->
  let var = Obj.dup var in
  let payload = get_payload var in
  if Obj.size payload <> 3 then
    failwith (Printf.sprintf "remove_role_part: unexpected tuple size: %d (expected: 3)" (Obj.size var))
  else
    let (_,msg,sess) = Obj.obj payload in
    let new_payload = Obj.repr (msg,sess) in
    Obj.set_field var 1 new_payload;
    var

(* unsafe: fun (`tag(msg,_)) new_sess -> `tag(msg,new_sess) *)
let replace_sess_part : 'a -> 'b -> 'a = fun var new_sess ->
  let var = Obj.dup (Obj.repr var) in
  let old_payload = get_payload var in
  if Obj.size old_payload <> 2 then
    failwith (Printf.sprintf "replace_sess_part: unexpected tuple size: %d (expected: 2)" (Obj.size old_payload))
  else
    let (msg,_) = Obj.obj old_payload in
    let new_payload = Obj.repr (msg,new_sess) in
    Obj.obj (replace_payload var new_payload)
