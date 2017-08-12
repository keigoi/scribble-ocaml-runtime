open Linocaml.Base
open Linocaml.Lens
open Base

module Make(E:Base.ENDPOINT) (* : SESSION with module Endpoint = E *)
= struct
  module Endpoint = E
  module LinIO = Endpoint.LinIO
  module IO = Endpoint.LinIO.IO

  type 'a lin = 'a Linocaml.Base.lin
  type 'a data = 'a Linocaml.Base.data

  type ('r,'c) role = 'c E.conn E.role
  type 'p sess_ = EP of Endpoint.t | Dummy
  type 'p sess = 'p sess_ lin
  type 'a connect = 'a

  let unsess = function
    | (Lin_Internal__ (EP s)) -> s
    | _ -> failwith "no session -- malformed ppx expansion??"

  (** invariant: 'br must be [`tag of 'a * 'b * 'c sess] *)
  let send :
        ([ `send of 'br ] sess, 'p sess, 'pre, 'post) slot ->
        ('r,'c) role -> ('br, ('r,'c) role * 'v data * 'p sess) lab -> 'v -> ('pre, 'post, unit) Endpoint.LinIO.monad
    = fun {get;put} dir {_pack} v ->
    LinIO.Internal.__monad begin
        fun pre ->
        let s = unsess (get pre) in
        print_endline (E.myname s ^ ": connect to " ^ E.string_of_role dir);
        let c = E.get_connection s ~otherrole:dir in
        let open IO in
        c.E.send c.E.conn (_pack (dir,Data_Internal__ v,Lin_Internal__ Dummy)) >>= fun () ->
        return (put pre (Lin_Internal__ (EP s)), ())
      end

  (** invariant: 'br must be [`tag of 'a * 'b * 'c sess] *)
  let deleg_send
      : type br dir c v p q pre mid post.
             ([`send of br] sess, p sess, pre, mid) slot
             -> (dir,c) role
             -> (br, (dir,c) role * q sess * p sess) lab
             -> (q sess, empty, mid, post) slot
             -> (pre, post, unit) LinIO.monad
    = fun {get=get1;put=put1} dir {_pack} {get=get2;put=put2} ->
    LinIO.Internal.__monad begin
        fun pre ->
        let s = unsess (get1 pre) in
        let mid = put1 pre (Lin_Internal__ (EP s)) in
        let t = get2 mid in
        print_endline (E.myname s ^ ": send to " ^ E.string_of_role dir);
        let c = E.get_connection s ~otherrole:dir in
        let open IO in
        (* we put Dummy for 'p sess part since the connection hash should not be shared with the others *)
        c.E.send c.E.conn (_pack (dir,t,Lin_Internal__ Dummy)) >>= fun _ ->
        return (put2 mid Linocaml.Base.Empty, ())
      end
    
  (** invariant: 'br must be [`tag of 'a * 'b sess] *)
  let receive
      :  type br dir c p pre xx post v.
              ([`recv of (dir,c) role * br] sess, empty, pre, post) slot
              -> (dir,c) role
              -> (pre, post, br lin) Endpoint.LinIO.monad =
    fun {get;put} dir ->
    LinIO.Internal.__monad begin
        fun pre ->
        let s = unsess (get pre) in
        print_endline (E.myname s ^ ": receive from " ^ E.string_of_role dir);
        let c = E.get_connection s ~otherrole:dir in
        let open IO in
        c.E.receive c.E.conn >>= fun (br : br) ->
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
      : type br dir c v p q pre post.
             ([`send of br] sess, p sess, pre, post) slot
             -> c E.connector
             -> (dir,c) role
             -> (br, (dir,c) role connect * v data * p sess) lab
             -> v
             -> (pre, post, unit) LinIO.monad
    = fun {get;put} connector dir {_pack} v ->
    LinIO.Internal.__monad begin
        fun pre ->
        let s = unsess (get pre) in
        print_endline (E.myname s ^ ": connect to " ^ E.string_of_role dir);
        let open IO in
        connector () >>= fun conn ->
        E.attach s dir conn;
        conn.E.send conn.E.conn (_pack (dir,Data_Internal__ v,Lin_Internal__ Dummy)) >>= fun () ->
        return (put pre (Lin_Internal__ (EP s)), ())
      end

  (** invariant: 'br must be [`tag of 'a * 'b sess] *)
  let accept
      :  type br dir c p pre xx post v.
              ([`accept of (dir,c) role * br] sess, empty, pre, post) slot
             -> c E.acceptor
              -> (dir,c) role
              -> (pre, post, br lin) LinIO.monad =
    fun {get;put} acceptor dir ->
    LinIO.Internal.__monad begin
        fun pre ->
        let s = unsess (get pre) in
        print_endline (E.myname s ^ ": accept from " ^ E.string_of_role dir);
        let open IO in
        acceptor () >>= fun conn ->
        E.attach s dir conn;
        conn.E.receive conn.E.conn >>= fun (br : br)(*polyvar*) ->
        (* we must replace 'p sess part, since the part in payload is Dummy (see send) *)
        let br = Unsafe.obj_conv_msg br (Lin_Internal__ (EP s)) in
        print_endline (E.myname s ^ ": received");
        return (put pre Empty, Lin_Internal__ br)
      end

  let disconnect
      : type br dir c v p q pre post.
             ([`disconnect of br] sess, p sess, pre, post) slot
             -> (dir,c) role
             -> (br, (dir,c) role * unit data * p sess) lab
             -> unit
             -> (pre, post, unit) LinIO.monad
    = fun {get;put} dir {_pack} v ->
    LinIO.Internal.__monad begin
        fun pre ->
        let s = unsess (get pre) in
        let c = E.get_connection s ~otherrole:dir in
        print_endline (E.myname s ^ ": disconnect from " ^ E.string_of_role dir);
        let open IO in
        c.E.close c.E.conn >>= fun () ->
        return (put pre (Lin_Internal__ (EP s)), ())
      end
    
  module Internal = struct
    (* val __new_connect_later_channel : string list -> ('g,[`Explicit]) channel *)
    
    let __mkrole : 'c E.rolekind -> string -> ('a,'c) role = E.make_role
                                              
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
