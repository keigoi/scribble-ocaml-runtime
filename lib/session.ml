open Linocaml.Base
open Linocaml.Lens

module Make(LinIO:Linocaml.Base.LIN_IO)
           (Chan:Base.CHAN with type 'a io = 'a LinIO.IO.io)
           (RawChan:Base.RAW_DCHAN with type 'a io = 'a LinIO.IO.io)
           (ConnKind:Base.CONN_KIND with type shmem_chan = RawChan.t)
: Base.SESSION with type 'a io = 'a LinIO.IO.io and type ('p,'q,'a) monad = ('p,'q,'a) LinIO.monad and module Endpoint.ConnKind = ConnKind
= struct
  module Endpoint = Endpoint.Make(LinIO.IO)(ConnKind)
  module LinIO = LinIO
  module IO = LinIO.IO
  module E = Endpoint

  type 'a io = 'a LinIO.IO.io
  type ('p,'q,'a) monad = ('p,'q,'a) LinIO.monad

  module Sender = struct
    type ('c,'v) t = ('c -> 'v -> unit IO.io, [%imp Senders]) Ppx_implicits.t
    let unpack : ('c,'v) t -> 'c -> 'v -> unit IO.io = fun d -> Ppx_implicits.imp ~d
  end
  module Receiver = struct
    type ('c,'v) t = ('c -> 'v IO.io, [%imp Receivers]) Ppx_implicits.t
    let unpack : ('c,'v) t -> 'c -> 'v IO.io = fun d -> Ppx_implicits.imp ~d
  end
  module Senders = struct
    let _f = RawChan.send
  end
  module Receivers = struct
    let _f = RawChan.receive
  end

  type 'a lin = 'a Linocaml.Base.lin
  type 'a data = 'a Linocaml.Base.data

  type ('r,'c) role = 'c Endpoint.key
  type 'p sess_ = EP of Endpoint.t | Dummy
  type 'p sess = 'p sess_ lin
  type 'a connect = 'a

  type ('br, 'payload) lab = {
      _pack : 'payload -> 'br
    }

  let unsess = function
    | (Lin_Internal__ (EP s)) -> s
    | _ -> failwith "no session -- malformed ppx expansion??"

  let untrans = function
    | Some f -> f
    | None -> failwith "no instance -- ppx_implicits not configured?"

  (** invariant: 'br must be [`tag of 'a * 'b * 'c sess] *)
  let send : type c v br p pre post r p.
                  ?_sender:(c,br) Sender.t ->
                  ([ `send of br ] sess, empty, pre, post) slot ->
                  (r,c) role -> (br, (r,c) role * v data * p sess) lab -> v -> (pre, post, p sess) LinIO.monad
    = fun ?_sender {get;put} dir {_pack} v ->
    LinIO.Internal.__monad begin
        fun pre ->
        let s = unsess (get pre) in
        print_endline (E.myname s ^ ": send to " ^ E.string_of_key dir);
        let c = E.get_connection s dir in
        let sender = Sender.unpack @@ untrans _sender in
        let open IO in
        sender c.E.handle (_pack (dir,Data_Internal__ v,Lin_Internal__ Dummy)) >>= fun () ->
        return (put pre Empty, Lin_Internal__ (EP s))
      end

  (** invariant: 'br must be [`tag of 'a * 'b * 'c sess] *)
  let deleg_send
      : type br dir c v p q pre mid post.
             ?_sender:(c,br) Sender.t
             -> ([`send of br] sess, p sess, pre, mid) slot
             -> (dir,c) role
             -> (br, (dir,c) role * q sess * p sess) lab
             -> (q sess, empty, mid, post) slot
             -> (pre, post, unit lin) LinIO.monad
    = fun ?_sender {get=get1;put=put1} dir {_pack} {get=get2;put=put2} ->
    LinIO.Internal.__monad begin
        fun pre ->
        let s = unsess (get1 pre) in
        let mid = put1 pre (Lin_Internal__ (EP s)) in
        let t = get2 mid in
        print_endline (E.myname s ^ ": send to " ^ E.string_of_key dir);
        let c = E.get_connection s dir in
        let sender = Sender.unpack @@ untrans _sender in
        let open IO in
        (* we put Dummy for 'p sess part since the connection hash should not be shared with the others *)
        sender c.E.handle (_pack (dir,t,Lin_Internal__ Dummy)) >>= fun _ ->
        return (put2 mid Linocaml.Base.Empty, Lin_Internal__ ())
      end

  (** invariant: 'br must be [`tag of 'a * 'b sess] *)
  let receive
      :  type br dir c p pre xx post v.
              ?_receiver:(c,br) Receiver.t
              -> ([`recv of (dir,c) role * br] sess, empty, pre, post) slot
              -> (dir,c) role
              -> (pre, post, br lin) LinIO.monad =
    fun ?_receiver {get;put} dir ->
    LinIO.Internal.__monad begin
        fun pre ->
        let s = unsess (get pre) in
        print_endline (E.myname s ^ ": receive from " ^ E.string_of_key dir);
        let c = E.get_connection s dir in
        let receiver = Receiver.unpack @@ untrans _receiver in
        let open IO in
        receiver c.E.handle >>= fun (br : br) ->
        (* we must replace 'p sess part, since the part in payload is Dummy (see send) *)
        let br = Unsafe.obj_conv_msg br (Lin_Internal__ (EP s)) in
        print_endline (E.myname s ^ ": received");
        return (put pre Empty, Lin_Internal__ br)
      end

  let close
      : type pre post.
             ([`close] sess, empty, pre, post) slot -> (pre, post, unit lin) LinIO.monad
    = fun {get;put} ->
    LinIO.Internal.__monad begin
        fun pre ->
        let s = unsess (get pre) in
        print_endline (E.myname s ^ ": close");
        (* E.close s >>= fun _ -> *)
        IO.return (put pre Empty, Lin_Internal__ ())
      end

  let connect
      : type br dir c v p q pre post.
             ?_sender:(c,br) Sender.t
             -> ([`send of br] sess, empty, pre, post) slot
             -> c Endpoint.connector
             -> (dir,c) role
             -> (br, (dir,c) role connect * v data * p sess) lab
             -> v
             -> (pre, post, p sess) LinIO.monad
    = fun ?_sender {get;put} connector dir {_pack} v ->
    LinIO.Internal.__monad begin
        fun pre ->
        let s = unsess (get pre) in
        let sender = Sender.unpack @@ untrans _sender in
        print_endline (E.myname s ^ ": connect to " ^ E.string_of_key dir);
        let open IO in
        connector () >>= fun conn ->
        E.attach s dir conn;
        sender conn.E.handle (_pack (dir,Data_Internal__ v,Lin_Internal__ Dummy)) >>= fun () ->
        return (put pre Empty, Lin_Internal__ (EP s))
      end

  (** invariant: 'br must be [`tag of 'a * 'b sess] *)
  let accept
      :  type br dir c p pre xx post v.
              ?_receiver:(c,br) Receiver.t
              -> ([`accept of (dir,c) role * br] sess, empty, pre, post) slot
              -> c E.acceptor
              -> (dir,c) role
              -> (pre, post, br lin) LinIO.monad =
    fun ?_receiver {get;put} acceptor dir ->
    LinIO.Internal.__monad begin
        fun pre ->
        let s = unsess (get pre) in
        print_endline (E.myname s ^ ": accept from " ^ E.string_of_key dir);
        let open IO in
        acceptor () >>= fun conn ->
        E.attach s dir conn;
        let receiver = Receiver.unpack @@ untrans _receiver in
        receiver conn.E.handle >>= fun (br : br)(*polyvar*) ->
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
             -> (pre, post, unit lin) LinIO.monad
    = fun {get;put} dir {_pack} ->
    LinIO.Internal.__monad begin
        fun pre ->
        let s = unsess (get pre) in
        print_endline (E.myname s ^ ": disconnect from " ^ E.string_of_key dir);
        let open IO in
        E.close s >>= fun _ ->
        return (put pre (Lin_Internal__ (EP s)), Lin_Internal__ ())
      end

  let initiate : myname:string -> ('c, 'c, 'p sess) LinIO.monad
    = fun ~myname ->
    LinIO.Internal.__monad begin
        fun pre ->
        let s = E.create ~myname in
        IO.return (pre, (Lin_Internal__ (EP s)))
      end

  let attach :
        ('p sess, 'p sess, 'ss, 'ss) slot -> ('r,'c) role -> 'c Endpoint.conn -> ('ss, 'ss, unit lin) LinIO.monad
    = fun {get;put} dir conn ->
    LinIO.Internal.__monad begin
        fun pre ->
        let s = unsess (get pre) in
        E.attach s dir conn;
        IO.return (pre, Lin_Internal__ ())
      end

  let detach :
        ('p sess, 'p sess, 'ss, 'ss) slot -> ('r, 'c) role -> ('ss, 'ss, 'c Endpoint.conn data lin) LinIO.monad
    = fun {get;put} dir ->
    LinIO.Internal.__monad begin
        fun pre ->
        let s = unsess (get pre) in
        let conn = E.detach s dir in
        IO.return (pre, Lin_Internal__ (Data_Internal__ conn))
      end

  module Shmem = struct
    type s = (string, RawChan.t) Hashtbl.t
    type 'g channel = {roles: string list; channels:(string, s Chan.t) Hashtbl.t}

    let create_channel : roles:string list -> 'g channel =
      fun ~roles ->
      let tbl = Hashtbl.create 42 in
      List.iter (fun role -> Hashtbl.add tbl role (Chan.create ())) roles;
      {roles; channels=tbl}
  end

  module Internal = struct
    (* val __new_connect_later_channel : string list -> ('g,[`Explicit]) channel *)

    let __mkrole : 'c Endpoint.ConnKind.t -> string -> ('r,'c) role = E.create_key

    let to_assoc tbl =
      let r = ref [] in
      Hashtbl.iter (fun k v -> r := (k,v)::!r) tbl;
      !r

    let rec create_endpoint myname assoc =
      let ep = Endpoint.create ~myname in
      List.iter (fun (rolename,raw) ->
          let key = Endpoint.create_key Endpoint.ConnKind.shmem_chan_kind rolename in
          Endpoint.attach ep key {Endpoint.handle=raw; close=(fun _ -> IO.return ())})
                assoc;
      ep

    let __accept : 'g Shmem.channel -> ('r, Endpoint.ConnKind.shmem_chan) role -> ('ss, 'ss, 'p sess) LinIO.monad =
      fun {Shmem.roles; channels} role ->

      (* hashtbl to record sessions between (r1,r2) *)
      let all = Hashtbl.create 42 in

      (* a function to create the session channel between r1 and r2 *)
      let create_or_get_conn r1 r2 =
        try
          Hashtbl.find all (r1,r2)
        with
        | Not_found ->
           try
             RawChan.reverse (Hashtbl.find all (r2,r1))
           with
           | Not_found -> begin
               let s = RawChan.create () in
               Hashtbl.add all (r1,r2) s;
               s
             end
      in
      let create_session r =
            let others = List.filter (fun r2 -> r2<>r) roles in
            let sess = Hashtbl.create 42 in
            List.iter (fun other ->
                let conn = create_or_get_conn r other in
                Hashtbl.add sess other conn) others;
            sess
      in
      let open IO in
      let rec send_all = function
        | [] -> return ()
        | r::rs ->
           let sess = create_session r in
           Chan.send (Hashtbl.find channels r) sess >>= fun _ ->
           send_all rs
      in
      let myname = Endpoint.string_of_key role in
      LinIO.lift begin
        print_endline ("myname:" ^ myname);
        let others = List.filter (fun r -> r<>myname) roles in
        send_all others >>= fun _ ->
        let ep = create_endpoint myname (to_assoc (create_session myname)) in
        return (EP ep)
      end

    let __connect : 'g Shmem.channel -> ('r, Endpoint.ConnKind.shmem_chan) role -> ('ss, 'ss, 'p sess) LinIO.monad =
      fun {Shmem.roles; channels} myrole ->
      let myname = Endpoint.string_of_key myrole in
      let open IO in
      LinIO.lift begin
          print_endline ("myname:" ^ myname);
          Chan.receive (Hashtbl.find channels myname) >>= fun sess ->
          let ep = create_endpoint myname (to_assoc sess) in
          return (EP ep)
        end
  end
end
