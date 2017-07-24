open Multiparty_base
open Linocaml
open Lens

type ('pre,'post,'v) monad = ('pre,'post,'v) Linocaml.monad
type ('a, 'pre,'post,'b) bind = ('a, 'pre,'post,'b) Linocaml.bind
let (>>>==) = Linocaml.(>>>==)
let (>>=) = Linocaml.(>>=)
let (>>) = Linocaml.(>>)
let return = Linocaml.return

type ('a,'b,'pre,'post) slot = ('a,'b,'pre,'post) Lens.t
type empty = Linocaml.empty
type 'a data = 'a Linocaml.data
type 'a lin = 'a Linocaml.lin

type ('g,'c) channel = 'c MChan.shared
type 'p sess_  = MChan of MChan.t | Dummy
type 'p sess = 'p sess_ lin

type 'r role = string

type 'a connect = 'a

type ('br, 'payload) lab = {_pack: 'payload -> 'br}

let __mkrole s = s

let new_channel = MChan.create
let new_lazy_channel = MChan.create_lazy
let __new_connect_later_channel roles = MChan.create_later roles

let __initiate : 'c 'p. myname:string -> [`Explicit] MChan.shared -> ('pre,'post,'p sess) monad =
  fun ~myname ch ->
  Linocaml.linret_ (fun () ->
      let s = MChan.initiate ch ~myname in
      MChan s)
  
let __connect : 'c 'p. myname:string -> [`Implicit] MChan.shared -> ('c,'c,'p sess) monad =
  fun ~myname ch ->
  Linocaml.linret_ (fun () ->
      let s = MChan.connect ch ~myname in
      MChan s)

let __accept : 'c 'p. myname:string -> cli_count:int -> [`Implicit] MChan.shared -> ('c,'c,'p sess) monad =
  fun ~myname ~cli_count ch ->
  Linocaml.linret_ (fun () ->
      let s = MChan.accept ch ~myname ~cli_count in
      MChan s)
                              
let connect
    : type br dir v p q pre post.
      ([`send of br] sess, p sess, pre, post) slot
      -> dir role
      -> (br, dir role connect * v data * p sess) lab
      -> v
      -> (pre, post, unit) monad
  = fun {get;put} dir {_pack} v ->
  Linocaml.Internal.__monad begin fun pre ->
      let s = match get pre with (Lin_Internal__ (MChan s)) -> s | _ -> failwith "no session -- malformed ppx expansion?? @ connect" in
      print_endline (MChan.myname s ^ ": connect to " ^ dir);
      MChan.connect_ongoing s ~to_:dir; (* explicit connection *)
      let uc = MChan.get_connection s ~othername:dir in
      Unsafe.UChan.send uc (_pack (dir,Data_Internal__ v,Lin_Internal__ Dummy));
      put pre (Lin_Internal__ (MChan s)), ()
    end

(** invariant: 'br must be [`tag of 'a * 'b sess] *)
let accept
    :  type br dir p pre xx post v.
       ([`accept of dir role * br] sess, empty, pre, post) slot
       -> dir role
       -> (pre, post, br lin) monad =
  fun {get;put} dir ->
  Linocaml.Internal.__monad begin
      fun pre ->
      let s = match get pre with Lin_Internal__ (MChan s) -> s | _ -> failwith "no session -- malformed ppx expansion?? @ __receive" in
      print_endline (MChan.myname s ^ ": accept from " ^ dir);
      MChan.accept_ongoing s ~from_:dir; (* explicit connection *)
      let uc = MChan.get_connection s ~othername:dir in
      let (br : br)(*polyvar*) = Unsafe.UChan.receive uc in
      (* we must replace 'p sess part, since the part in payload is Dummy (see send) *)
      let br = Unsafe.obj_conv_msg br (Lin_Internal__ (MChan s)) in
      print_endline (MChan.myname s ^ ": received");
      put pre Empty, Lin_Internal__ br
    end

let disconnect
    : type br dir v p q pre post.
      ([`disconnect of br] sess, p sess, pre, post) slot
      -> dir role
      -> (br, dir role * unit data * p sess) lab
      -> unit
      -> (pre, post, unit) monad
  = fun {get;put} dir {_pack} v ->
  Internal.__monad begin
      fun pre ->
      let s = match get pre with Lin_Internal__ (MChan s) -> s | _ -> failwith "no session -- malformed ppx expansion?? @ connect" in
      print_endline (MChan.myname s ^ ": disconnect from " ^ dir);
      MChan.disconnect s ~from_:dir;
      put pre (Lin_Internal__ (MChan s)), ()
    end

(** invariant: 'br must be [`tag of 'a * 'b * 'c sess] *)
let send
    : type br dir v p q pre post.
      ([`send of br] sess, p sess, pre, post) slot
      -> dir role
      -> (br, dir role * v data * p sess) lab
      -> v
      -> (pre, post, unit) monad
  = fun {get;put} dir {_pack} v ->
  Internal.__monad begin
      fun pre ->
      let s = match get pre with (Lin_Internal__ (MChan s)) -> s | _ -> failwith "no session -- malformed ppx expansion?? @ send" in
      print_endline (MChan.myname s ^ ": send to " ^ dir);
      let uc = MChan.get_connection s ~othername:dir in
      (* we put Dummy for 'p sess part since the connection hash should not be shared with the others *)
      Unsafe.UChan.send uc (_pack (dir,Data_Internal__ v,Lin_Internal__ Dummy));
      put pre (Lin_Internal__ (MChan s)), ()
    end

(** invariant: 'br must be [`tag of 'a * 'b * 'c sess] *)
let deleg_send
    : type br dir v p q pre mid post.
      ([`send of br] sess, p sess, pre, mid) slot
      -> dir role
      -> (br, dir role * q sess * p sess) lab
      -> (q sess, empty, mid, post) slot
      -> (pre, post, unit) monad
  = fun {get=get1;put=put1} dir {_pack} {get=get2;put=put2} ->
  Internal.__monad begin
      fun pre ->
      let s = match get1 pre with (Lin_Internal__ (MChan s)) -> s | Lin_Internal__ Dummy -> failwith "no session -- malformed ppx expansion?? @ send" in
      let mid = put1 pre (Lin_Internal__ (MChan s)) in
      let t = get2 mid in
      print_endline (MChan.myname s ^ ": send to " ^ dir);
      let uc = MChan.get_connection s ~othername:dir in
      (* we put Dummy for 'p sess part since the connection hash should not be shared with the others *)
      Unsafe.UChan.send uc (_pack (dir,t,Lin_Internal__ Dummy));
      put2 mid Linocaml.Empty, ()
    end

(** invariant: 'br must be [`tag of 'a * 'b sess] *)
let receive
    :  type br dir p pre xx post v.
       ([`recv of dir role * br] sess, empty, pre, post) slot
       -> dir role
       -> (pre, post, br lin) monad =
  fun {get;put} dir ->
  Linocaml.Internal.__monad begin
      fun pre ->
      let s = match get pre with Lin_Internal__ (MChan s) -> s | Lin_Internal__ Dummy -> failwith "no session -- malformed ppx expansion?? @ __receive" in
      print_endline (MChan.myname s ^ ": receive from " ^ dir);
      let uc = MChan.get_connection s ~othername:dir in
      let (br : br)(*polyvar*) = Unsafe.UChan.receive uc in
      (* we must replace 'p sess part, since the part in payload is Dummy (see send) *)
      let br = Unsafe.obj_conv_msg br (Lin_Internal__ (MChan s)) in
      print_endline (MChan.myname s ^ ": received");
      put pre Empty, Lin_Internal__ br
    end

let close
    : type pre post.
      ([`close] sess, empty, pre, post) slot -> (pre, post, unit) monad
  = fun {get;put} ->
  Internal.__monad begin
      fun pre ->
      let s = match get pre with Lin_Internal__ (MChan s) -> s | Lin_Internal__ Dummy -> failwith "no session -- malformed ppx?? @ close" in
      print_endline (MChan.myname s ^ ": close");
      put pre Empty, ()
    end

module Internal = struct
  let __new_connect_later_channel =  __new_connect_later_channel
  let __mkrole = __mkrole
  let __initiate = __initiate
  let __connect = __connect
  let __accept = __accept
end
