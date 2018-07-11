(* Generated from scribble-ocaml https://github.com/keigoi/scribble-ocaml
 * This code should be compiled with scribble-ocaml-runtime
 * https://github.com/keigoi/scribble-ocaml-runtime *)


module Make (Session:Scribble.S.SESSION)  = struct


open Session

type ('c_S) rPC_C = ('c_S) rPC_C_1
and ('c_S) rPC_C_1 =
  [`send of [`S of 'c_S * [`M1 of unit data *
    [`recv of [`S of 'c_S * [`M2 of unit data *
      [`close] sess]]] sess]]]
type ('c_C) rPC_S = ('c_C) rPC_S_1
and ('c_C) rPC_S_1 =
  [`recv of [`C of 'c_C * [`M1 of unit data *
    [`send of [`C of 'c_C * [`M2 of unit data *
      [`close] sess]]] sess]]]


module Shmem = Scribble.Shmem.Make(Session.LinIO.IO)(Session.Mutex)(Session.Condition)(Session.Endpoint)

type rPC = ShmemMPSTChanenl__ of Shmem.MPSTChannel.t
let create_shmem_channel : unit -> rPC = fun () ->
  ShmemMPSTChanenl__(Shmem.MPSTChannel.create ~acceptor_role:"role_C" ~connector_roles:["role_S";])


module C = struct
  let initiate_shmem : 'c. rPC -> ('c, 'c, Shmem.Raw.t rPC_C sess) monad = fun (ShmemMPSTChanenl__(c)) ->
    Internal.__start (Shmem.MPSTChannel.accept c ~role:"role_C")

  module S = struct
    module Make(X:sig
        type conn
        val conn : conn Endpoint.conn_kind
        val write_m1 : conn -> [>`M1 of unit data * 'p sess] -> unit io
        val read_m2 : conn -> [`M2 of unit data * 'p0] io
      end) = struct
      type conn = X.conn
      let role : ([>`S of X.conn * 'lab], X.conn, 'lab) role =
        {_pack_role=(fun labels -> `S(labels)) ; _repr="role_S"; _kind=X.conn}

      let m1 : 'p. ([>`M1 of unit data * 'p sess], X.conn, unit data * 'p sess) label =
        {_pack_label=(fun payload -> `M1(payload)); _send=X.write_m1}
      let receive_m2  : type p0. ([`M2 of unit data * p0], X.conn) labels =
        {_receive=X.read_m2}
    end

    module Raw = struct
      include Make(struct
          type conn = Shmem.Raw.t
          let conn = Shmem.MPSTChannel.Raw
          let write_m1 = Shmem.Raw.send
          let read_m2 = Shmem.Raw.receive
        end)
    end
  end

end

module S = struct
  let initiate_shmem : 'c. rPC -> ('c, 'c, Shmem.Raw.t rPC_S sess) monad = fun (ShmemMPSTChanenl__(c)) ->
    Internal.__start (Shmem.MPSTChannel.connect c ~role:"role_S")

  module C = struct
    module Make(X:sig
        type conn
        val conn : conn Endpoint.conn_kind
        val write_m2 : conn -> [>`M2 of unit data * 'p sess] -> unit io
        val read_m1 : conn -> [`M1 of unit data * 'p0] io
      end) = struct
      type conn = X.conn
      let role : ([>`C of X.conn * 'lab], X.conn, 'lab) role =
        {_pack_role=(fun labels -> `C(labels)) ; _repr="role_C"; _kind=X.conn}

      let m2 : 'p. ([>`M2 of unit data * 'p sess], X.conn, unit data * 'p sess) label =
        {_pack_label=(fun payload -> `M2(payload)); _send=X.write_m2}
      let receive_m1  : type p0. ([`M1 of unit data * p0], X.conn) labels =
        {_receive=X.read_m1}
    end

    module Raw = struct
      include Make(struct
          type conn = Shmem.Raw.t
          let conn = Shmem.MPSTChannel.Raw
          let write_m2 = Shmem.Raw.send
          let read_m1 = Shmem.Raw.receive
        end)
    end
  end

end

end