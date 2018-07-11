(* Generated from scribble-ocaml https://github.com/keigoi/scribble-ocaml
 * This code should be compiled with scribble-ocaml-runtime
 * https://github.com/keigoi/scribble-ocaml-runtime *)


module Make (Session:Scribble.S.SESSION)  = struct


open Session

type ('c_R2, 'c_R3) relay_R1 = ('c_R2, 'c_R3) relay_R1_1
and ('c_R2, 'c_R3) relay_R1_1 =
  [`send of [`R2 of 'c_R2 * [`M1 of unit data *
    [`close] sess]]]
type ('c_R1, 'c_R3) relay_R2 = ('c_R1, 'c_R3) relay_R2_1
and ('c_R1, 'c_R3) relay_R2_1 =
  [`recv of [`R1 of 'c_R1 * [`M1 of unit data *
    [`send of [`R3 of 'c_R3 * [`M2 of unit data *
      [`close] sess]]] sess]]]
type ('c_R1, 'c_R2) relay_R3 = ('c_R1, 'c_R2) relay_R3_1
and ('c_R1, 'c_R2) relay_R3_1 =
  [`recv of [`R2 of 'c_R2 * [`M2 of unit data *
    [`close] sess]]]


module Shmem = Scribble.Shmem.Make(Session.LinIO.IO)(Session.Mutex)(Session.Condition)(Session.Endpoint)

type relay = ShmemMPSTChanenl__ of Shmem.MPSTChannel.t
let create_shmem_channel : unit -> relay = fun () ->
  ShmemMPSTChanenl__(Shmem.MPSTChannel.create ~acceptor_role:"role_R1" ~connector_roles:["role_R2";; "role_R3"])


module R1 = struct
  let initiate_shmem : 'c. relay -> ('c, 'c, Shmem.Raw.t relay_R1 sess) monad = fun (ShmemMPSTChanenl__(c)) ->
    Internal.__start (Shmem.MPSTChannel.accept c ~role:"role_R1")

  module R2 = struct
    module Make(X:sig
        type conn
        val conn : conn Endpoint.conn_kind
        val write_m1 : conn -> [>`M1 of unit data * 'p sess] -> unit io
      end) = struct
      type conn = X.conn
      let role : ([>`R2 of X.conn * 'lab], X.conn, 'lab) role =
        {_pack_role=(fun labels -> `R2(labels)) ; _repr="role_R2"; _kind=X.conn}

      let m1 : 'p. ([>`M1 of unit data * 'p sess], X.conn, unit data * 'p sess) label =
        {_pack_label=(fun payload -> `M1(payload)); _send=X.write_m1}
    end

    module Raw = struct
      include Make(struct
          type conn = Shmem.Raw.t
          let conn = Shmem.MPSTChannel.Raw
          let write_m1 = Shmem.Raw.send
        end)
    end
  end
  module R3 = struct
    module Make(X:sig
        type conn
        val conn : conn Endpoint.conn_kind
      end) = struct
      type conn = X.conn
      let role : ([>`R3 of X.conn * 'lab], X.conn, 'lab) role =
        {_pack_role=(fun labels -> `R3(labels)) ; _repr="role_R3"; _kind=X.conn}

    end

    module Raw = struct
      include Make(struct
          type conn = Shmem.Raw.t
          let conn = Shmem.MPSTChannel.Raw
        end)
    end
  end

end

module R2 = struct
  let initiate_shmem : 'c. relay -> ('c, 'c, Shmem.Raw.t relay_R2 sess) monad = fun (ShmemMPSTChanenl__(c)) ->
    Internal.__start (Shmem.MPSTChannel.connect c ~role:"role_R2")

  module R1 = struct
    module Make(X:sig
        type conn
        val conn : conn Endpoint.conn_kind
        val read_m1 : conn -> [`M1 of unit data * 'p0] io
      end) = struct
      type conn = X.conn
      let role : ([>`R1 of X.conn * 'lab], X.conn, 'lab) role =
        {_pack_role=(fun labels -> `R1(labels)) ; _repr="role_R1"; _kind=X.conn}

      let receive_m1  : type p0. ([`M1 of unit data * p0], X.conn) labels =
        {_receive=X.read_m1}
    end

    module Raw = struct
      include Make(struct
          type conn = Shmem.Raw.t
          let conn = Shmem.MPSTChannel.Raw
          let read_m1 = Shmem.Raw.receive
        end)
    end
  end
  module R3 = struct
    module Make(X:sig
        type conn
        val conn : conn Endpoint.conn_kind
        val write_m2 : conn -> [>`M2 of unit data * 'p sess] -> unit io
      end) = struct
      type conn = X.conn
      let role : ([>`R3 of X.conn * 'lab], X.conn, 'lab) role =
        {_pack_role=(fun labels -> `R3(labels)) ; _repr="role_R3"; _kind=X.conn}

      let m2 : 'p. ([>`M2 of unit data * 'p sess], X.conn, unit data * 'p sess) label =
        {_pack_label=(fun payload -> `M2(payload)); _send=X.write_m2}
    end

    module Raw = struct
      include Make(struct
          type conn = Shmem.Raw.t
          let conn = Shmem.MPSTChannel.Raw
          let write_m2 = Shmem.Raw.send
        end)
    end
  end

end

module R3 = struct
  let initiate_shmem : 'c. relay -> ('c, 'c, Shmem.Raw.t relay_R3 sess) monad = fun (ShmemMPSTChanenl__(c)) ->
    Internal.__start (Shmem.MPSTChannel.connect c ~role:"role_R3")

  module R1 = struct
    module Make(X:sig
        type conn
        val conn : conn Endpoint.conn_kind
      end) = struct
      type conn = X.conn
      let role : ([>`R1 of X.conn * 'lab], X.conn, 'lab) role =
        {_pack_role=(fun labels -> `R1(labels)) ; _repr="role_R1"; _kind=X.conn}

    end

    module Raw = struct
      include Make(struct
          type conn = Shmem.Raw.t
          let conn = Shmem.MPSTChannel.Raw
        end)
    end
  end
  module R2 = struct
    module Make(X:sig
        type conn
        val conn : conn Endpoint.conn_kind
        val read_m2 : conn -> [`M2 of unit data * 'p0] io
      end) = struct
      type conn = X.conn
      let role : ([>`R2 of X.conn * 'lab], X.conn, 'lab) role =
        {_pack_role=(fun labels -> `R2(labels)) ; _repr="role_R2"; _kind=X.conn}

      let receive_m2  : type p0. ([`M2 of unit data * p0], X.conn) labels =
        {_receive=X.read_m2}
    end

    module Raw = struct
      include Make(struct
          type conn = Shmem.Raw.t
          let conn = Shmem.MPSTChannel.Raw
          let read_m2 = Shmem.Raw.receive
        end)
    end
  end

end

end