module Make(Chan:Base.CHAN)
       : sig
  type +'a io = 'a Chan.io
  type 'a t
  val create : unit -> 'a t
  val send : 'a t -> 'a -> unit Chan.io
  val receive : 'a t -> 'a Chan.io
  val reverse : 'a t -> 'a t
end
  = struct
  type +'a io = 'a Chan.io
  type 'a t = 'a Chan.t * 'a Chan.t

  let create () = Chan.create (), Chan.create ()
  let send (w,_) v = Chan.send w v
  let receive (_,r) = Chan.receive r
  let reverse (w,r) = (r,w)
end
