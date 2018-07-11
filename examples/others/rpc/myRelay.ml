(* Generated from scribble-ocaml https://github.com/keigoi/scribble-ocaml
 * This code should be compiled with scribble-ocaml-runtime
 * https://github.com/keigoi/scribble-ocaml-runtime *)


module Make (Session:Scribble.S.SESSION)  = struct


open Session

type ('c_B, 'c_C) myRelay_A = ('c_B, 'c_C) myRelay_A_1
and ('c_B, 'c_C) myRelay_A_1 =
  [`send of [`B of 'c_B * [`M of unit data *
    [`close] sess]]]
type ('c_A, 'c_C) myRelay_B = ('c_A, 'c_C) myRelay_B_1
and ('c_A, 'c_C) myRelay_B_1 =
  [`recv of [`A of 'c_A * [`M of unit data *
    [`send of [`C of 'c_C * [`M of unit data *
      [`close] sess]]] sess]]]
type ('c_A, 'c_B) myRelay_C = ('c_A, 'c_B) myRelay_C_1
and ('c_A, 'c_B) myRelay_C_1 =
  [`recv of [`B of 'c_B * [`M of unit data *
    [`close] sess]]]


module Shmem = Scribble.Shmem.Make(Session.LinIO.IO)(Session.Mutex)(Session.Condition)(Session.Endpoint)

type myRelay = ShmemMPSTChanenl__ of Shmem.MPSTChannel.t
let create_shmem_channel : unit -> myRelay = fun () ->
  ShmemMPSTChanenl__(Shmem.MPSTChannel.create ~acceptor_role:"role_A" ~connector_roles:["role_B";; "role_C"])


module A = struct
  let initiate_shmem : 'c. myRelay -> ('c, 'c, Shmem.Raw.t myRelay_A sess) monad = fun (ShmemMPSTChanenl__(c)) ->
    Internal.__start (Shmem.MPSTChannel.accept c ~role:"role_A")

  module B = struct
    module Make(X:sig
        type conn
        val conn : conn Endpoint.conn_kind
        val write_m : conn -> [>`M of unit data * 'p sess] -> unit io
      end) = struct
      type conn = X.conn
      let role : ([>`B of X.conn * 'lab], X.conn, 'lab) role =
        {_pack_role=(fun labels -> `B(labels)) ; _repr="role_B"; _kind=X.conn}

      let m : 'p. ([>`M of unit data * 'p sess], X.conn, unit data * 'p sess) label =
        {_pack_label=(fun payload -> `M(payload)); _send=X.write_m}
    end

    module Raw = struct
      include Make(struct
          type conn = Shmem.Raw.t
          let conn = Shmem.MPSTChannel.Raw
          let write_m = Shmem.Raw.send
        end)
    end
  end
  module C = struct
    module Make(X:sig
        type conn
        val conn : conn Endpoint.conn_kind
      end) = struct
      type conn = X.conn
      let role : ([>`C of X.conn * 'lab], X.conn, 'lab) role =
        {_pack_role=(fun labels -> `C(labels)) ; _repr="role_C"; _kind=X.conn}

    end

    module Raw = struct
      include Make(struct
          type conn = Shmem.Raw.t
          let conn = Shmem.MPSTChannel.Raw
        end)
    end
  end

end

module B = struct
  let initiate_shmem : 'c. myRelay -> ('c, 'c, Shmem.Raw.t myRelay_B sess) monad = fun (ShmemMPSTChanenl__(c)) ->
    Internal.__start (Shmem.MPSTChannel.connect c ~role:"role_B")

  module A = struct
    module Make(X:sig
        type conn
        val conn : conn Endpoint.conn_kind
        val read_m : conn -> [`M of unit data * 'p0] io
      end) = struct
      type conn = X.conn
      let role : ([>`A of X.conn * 'lab], X.conn, 'lab) role =
        {_pack_role=(fun labels -> `A(labels)) ; _repr="role_A"; _kind=X.conn}

      let receive_m  : type p0. ([`M of unit data * p0], X.conn) labels =
        {_receive=X.read_m}
    end

    module Raw = struct
      include Make(struct
          type conn = Shmem.Raw.t
          let conn = Shmem.MPSTChannel.Raw
          let read_m = Shmem.Raw.receive
        end)
    end
  end
  module C = struct
    module Make(X:sig
        type conn
        val conn : conn Endpoint.conn_kind
        val write_m : conn -> [>`M of unit data * 'p sess] -> unit io
      end) = struct
      type conn = X.conn
      let role : ([>`C of X.conn * 'lab], X.conn, 'lab) role =
        {_pack_role=(fun labels -> `C(labels)) ; _repr="role_C"; _kind=X.conn}

      let m : 'p. ([>`M of unit data * 'p sess], X.conn, unit data * 'p sess) label =
        {_pack_label=(fun payload -> `M(payload)); _send=X.write_m}
    end

    module Raw = struct
      include Make(struct
          type conn = Shmem.Raw.t
          let conn = Shmem.MPSTChannel.Raw
          let write_m = Shmem.Raw.send
        end)
    end
  end

end

module C = struct
  let initiate_shmem : 'c. myRelay -> ('c, 'c, Shmem.Raw.t myRelay_C sess) monad = fun (ShmemMPSTChanenl__(c)) ->
    Internal.__start (Shmem.MPSTChannel.connect c ~role:"role_C")

  module A = struct
    module Make(X:sig
        type conn
        val conn : conn Endpoint.conn_kind
      end) = struct
      type conn = X.conn
      let role : ([>`A of X.conn * 'lab], X.conn, 'lab) role =
        {_pack_role=(fun labels -> `A(labels)) ; _repr="role_A"; _kind=X.conn}

    end

    module Raw = struct
      include Make(struct
          type conn = Shmem.Raw.t
          let conn = Shmem.MPSTChannel.Raw
        end)
    end
  end
  module B = struct
    module Make(X:sig
        type conn
        val conn : conn Endpoint.conn_kind
        val read_m : conn -> [`M of unit data * 'p0] io
      end) = struct
      type conn = X.conn
      let role : ([>`B of X.conn * 'lab], X.conn, 'lab) role =
        {_pack_role=(fun labels -> `B(labels)) ; _repr="role_B"; _kind=X.conn}

      let receive_m  : type p0. ([`M of unit data * p0], X.conn) labels =
        {_receive=X.read_m}
    end

    module Raw = struct
      include Make(struct
          type conn = Shmem.Raw.t
          let conn = Shmem.MPSTChannel.Raw
          let read_m = Shmem.Raw.receive
        end)
    end
  end

end

end