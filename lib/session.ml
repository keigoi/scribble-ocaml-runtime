open Linocaml.Base
open Linocaml.Lens
open Base

module Make(E:Base.ENDPOINT) : SESSION with module Endpoint = E
= struct
  module Endpoint = E
  module LinIO = Endpoint.LinIO
  module IO = Endpoint.LinIO.IO

  type 'a lin = 'a Linocaml.Base.lin
  type 'a data = 'a Linocaml.Base.data

  type 'r role = string
  type 'p sess_ = EP of Endpoint.t | Dummy
  type 'p sess = 'p sess_ lin
  type 'a connect = 'a

  let unsess = function
    | (Lin_Internal__ (EP s)) -> s
    | _ -> failwith "no session -- malformed ppx expansion??"

  (** invariant: 'br must be [`tag of 'a * 'b * 'c sess] *)
  let send :
        ([ `send of 'br ] sess, 'p sess, 'pre, 'post) slot ->
        'r role -> ('br, 'r role * 'v data * 'p sess) lab -> 'v -> ('pre, 'post, unit) Endpoint.LinIO.monad
    = fun {get;put} dir {_pack} v ->
    LinIO.Internal.__monad begin
        fun pre ->
        let s = unsess (get pre) in
        print_endline (E.myname s ^ ": connect to " ^ dir);
        let module B = (val E.get_connection s ~othername:dir : E.BINARY_CONN) in
        let open IO in
        B.Binary.send B.conn (_pack (dir,Data_Internal__ v,Lin_Internal__ Dummy)) >>= fun () ->
        return (put pre (Lin_Internal__ (EP s)), ())
      end

  (** invariant: 'br must be [`tag of 'a * 'b * 'c sess] *)
  let deleg_send
      : type br dir v p q pre mid post.
             ([`send of br] sess, p sess, pre, mid) slot
             -> dir role
             -> (br, dir role * q sess * p sess) lab
             -> (q sess, empty, mid, post) slot
             -> (pre, post, unit) LinIO.monad
    = fun {get=get1;put=put1} dir {_pack} {get=get2;put=put2} ->
    LinIO.Internal.__monad begin
        fun pre ->
        let s = unsess (get1 pre) in
        let mid = put1 pre (Lin_Internal__ (EP s)) in
        let t = get2 mid in
        print_endline (E.myname s ^ ": send to " ^ dir);
        let module B = (val E.get_connection s ~othername:dir : E.BINARY_CONN) in
        let open IO in
        (* we put Dummy for 'p sess part since the connection hash should not be shared with the others *)
        B.Binary.send B.conn (_pack (dir,t,Lin_Internal__ Dummy)) >>= fun _ ->
        return (put2 mid Linocaml.Base.Empty, ())
      end
    
  (** invariant: 'br must be [`tag of 'a * 'b sess] *)
  let receive
      :  type br dir p pre xx post v.
              ([`recv of dir role * br] sess, empty, pre, post) slot
              -> dir role
              -> (pre, post, br lin) Endpoint.LinIO.monad =
    fun {get;put} dir ->
    LinIO.Internal.__monad begin
        fun pre ->
        let s = unsess (get pre) in
        print_endline (E.myname s ^ ": receive from " ^ dir);
        let module B = (val (E.get_connection s ~othername:dir) : E.BINARY_CONN) in
        let open IO in
        B.Binary.receive B.conn >>= fun (br : br) ->
        (* we must replace 'p sess part, since the part in payload is Dummy (see send) *)
        let br = Unsafe.obj_conv_msg br (Lin_Internal__ (EP s)) in
        print_endline (E.myname s ^ ": received");
        return (put pre Empty, Lin_Internal__ br)
      end
    
  let close
      : type pre post.
             ([`close] sess, empty, pre, post) slot -> (pre, post, unit) LinIO.monad
    = fun {get;put} ->
    LinIO.Internal.__monad begin
        fun pre ->
        let s = unsess (get pre) in
        print_endline (E.myname s ^ ": close");
        (* E.close s >>= fun _ -> *)
        IO.return (put pre Empty, ())
      end

  let connect
      : type br dir v p q pre post.
             ([`send of br] sess, p sess, pre, post) slot
             -> 'g E.connector
             -> dir role
             -> (br, dir role connect * v data * p sess) lab
             -> v
             -> (pre, post, unit) LinIO.monad
    = fun {get;put} connector dir {_pack} v ->
    LinIO.Internal.__monad begin
        fun pre ->
        let s = unsess (get pre) in
        print_endline (E.myname s ^ ": connect to " ^ dir);
        let open IO in
        connector () >>= fun conn ->
        E.attach s dir conn;
        let module B = (val conn : E.BINARY_CONN) in
        B.Binary.send B.conn (_pack (dir,Data_Internal__ v,Lin_Internal__ Dummy)) >>= fun () ->
        return (put pre (Lin_Internal__ (EP s)), ())
      end

  (** invariant: 'br must be [`tag of 'a * 'b sess] *)
  let accept
      :  type br dir p pre xx post v.
              ([`accept of dir role * br] sess, empty, pre, post) slot
             -> 'g E.acceptor
              -> dir role
              -> (pre, post, br lin) LinIO.monad =
    fun {get;put} acceptor dir ->
    LinIO.Internal.__monad begin
        fun pre ->
        let s = unsess (get pre) in
        print_endline (E.myname s ^ ": accept from " ^ dir);
        let open IO in
        acceptor () >>= fun conn ->
        E.attach s dir conn;
        let module B = (val conn : E.BINARY_CONN) in
        B.Binary.receive B.conn >>= fun (br : br)(*polyvar*) ->
        (* we must replace 'p sess part, since the part in payload is Dummy (see send) *)
        let br = Unsafe.obj_conv_msg br (Lin_Internal__ (EP s)) in
        print_endline (E.myname s ^ ": received");
        return (put pre Empty, Lin_Internal__ br)
      end

  let disconnect
      : type br dir v p q pre post.
             ([`disconnect of br] sess, p sess, pre, post) slot
             -> dir role
             -> (br, dir role * unit data * p sess) lab
             -> unit
             -> (pre, post, unit) LinIO.monad
    = fun {get;put} dir {_pack} v ->
    LinIO.Internal.__monad begin
        fun pre ->
        let s = unsess (get pre) in
        let module B = (val E.get_connection s ~othername:dir : E.BINARY_CONN) in
        print_endline (E.myname s ^ ": disconnect from " ^ dir);
        let open IO in
        B.Binary.close B.conn >>= fun () ->
        return (put pre (Lin_Internal__ (EP s)), ())
      end
    
  module Internal = struct
    (* val __new_connect_later_channel : string list -> ('g,[`Explicit]) channel *)
    
    let __mkrole : string -> 'a role = fun s -> s
                                              
    let __connect :
          myname:string ->
          roles:string list ->
          'g Endpoint.connector ->
          ('c, 'c, 'p sess) Endpoint.LinIO.monad = fun ~myname ~roles conn ->
      failwith "TODO"
      
    let __accept :
          myname:string ->
          roles:string list ->
          'g Endpoint.acceptor ->
          ('c, 'c, 'p sess) Endpoint.LinIO.monad = fun ~myname ~roles conn ->
      failwith "TODO"

               (* val __initiate : *)
               (*   myname:string -> *)
               (*   ('g,[`Explicit]) channel -> *)
               (*   ('c, 'c, 'p sess) monad *)
  end
       
end
