include Session.Make(Endpoint.Make(Linocaml.Direct))

module type CHAN = sig
  type +'a io
  type 'a t
  val create : unit -> 'a t io
  val send : 'a t -> 'a -> unit io
  val receive : 'a t -> 'a io
end

module Chan : CHAN with type 'a io = 'a = struct
  type 'a io = 'a
  type 'a t = 'a Event.channel
  let create     = Event.new_channel
  let send ch x  = Event.sync (Event.send ch x)
  let receive ch = Event.sync (Event.receive ch)
end

module Make_raw_chan(M:CHAN) = struct
  type +'a io = 'a M.io
  type t = unit M.t
  let create = M.create
  let send c v = M.send c (Obj.magic v)
  let receive c = Obj.magic (M.receive c)
  let close _ = ()
end
module RawChan = Make_raw_chan(Chan)
               
module SharedMemory : sig
  val create_endpoint : unit -> ('g Endpoint.acceptor * 'g Endpoint.connector)
end = struct
  let create_endpoint () =
    let make raw = 
      let module M = struct
          module Binary = RawChan
          let conn = raw
        end
      in
      (module M : Endpoint.BINARY_CONN)
    in
    let ch = Chan.create () in
    (fun () -> make (Chan.receive ch)),
    (fun () -> let raw = RawChan.create () in Chan.send ch raw; make raw)
end

(* module TCP : sig *)
(*   val connect : string -> int -> 'g Endpoint.connector *)
(* end = struct *)
(*   let make  *)
(*   let connect host port = *)
(* end *)

