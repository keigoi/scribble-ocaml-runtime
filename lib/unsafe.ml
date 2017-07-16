
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


module UChan : sig (* untyped *)
  type t
  val create : unit -> t
  val receive : t -> 'a
  val send : t -> 'a -> unit
end = struct
  type t = unit Event.channel
  let create = Event.new_channel
  let receive c = Obj.magic (Event.sync (Event.receive c))
  let send c v = Event.sync (Event.send c (Obj.magic v ))
end
