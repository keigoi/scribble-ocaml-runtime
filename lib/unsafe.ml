
(* unsafe: `tag(_,msg,_)==> `tag(msg,sess) *)
let obj_conv_msg : 'poly1 -> 'a -> 'poly2 = fun poly sess ->
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


module Make_raw_dchan(M:Base.DCHAN)
       : Base.RAW_DCHAN with type 'a io = 'a M.io
  = struct
  type +'a io = 'a M.io
  type t = unit M.t
  let create = M.create
  let send c v = M.send c (Obj.magic v)
  let receive c = Obj.magic (M.receive c)
  let reverse c = M.reverse c
end
