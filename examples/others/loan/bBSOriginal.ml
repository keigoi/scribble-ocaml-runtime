(* Generated from scribble-ocaml https://github.com/keigoi/scribble-ocaml
 * This code should be compiled with scribble-ocaml-runtime
 * https://github.com/keigoi/scribble-ocaml-runtime *)


module Make (Session:Scribble.S.SESSION)  = struct
  type int = java.lang.Integer
  type string = java.lang.String
  type bool = java.lang.Boolean

open Session

type ('c_ApplicationPortal, 'c_ProcessingDept, 'c_FinanceDept) bBSOriginal_Applicant = ('c_ApplicationPortal, 'c_ProcessingDept, 'c_FinanceDept) bBSOriginal_Applicant_1
and ('c_ApplicationPortal, 'c_ProcessingDept, 'c_FinanceDept) bBSOriginal_Applicant_1 =
  [`connect of [`ApplicationPortal of 'c_ApplicationPortal * [`msg of unit data *
    [`send of [`ApplicationPortal of 'c_ApplicationPortal * [`applyForLoan of (string * string * int * int) data *
      [`recv of [`ApplicationPortal of 'c_ApplicationPortal *
        [`requestConfirmation of int data *
          [`close] sess
        |`reject of unit data *
          [`close] sess]]] sess]]] sess]]]
type ('c_Applicant, 'c_ProcessingDept, 'c_FinanceDept) bBSOriginal_ApplicationPortal = ('c_Applicant, 'c_ProcessingDept, 'c_FinanceDept) bBSOriginal_ApplicationPortal_1
and ('c_Applicant, 'c_ProcessingDept, 'c_FinanceDept) bBSOriginal_ApplicationPortal_1 =
  [`accept of [`Applicant of 'c_Applicant * [`msg of unit data *
    [`connect of [`ProcessingDept of 'c_ProcessingDept * [`msg of unit data *
      [`recv of [`Applicant of 'c_Applicant * [`applyForLoan of (string * string * int * int) data *
        [`send of [`ProcessingDept of 'c_ProcessingDept * [`checkEligibility of (string * string * int * int) data *
          [`recv of [`ProcessingDept of 'c_ProcessingDept * [`respond of bool data *
            [`connect of
              [`Applicant of 'c_Applicant * [`reject of unit data *
                [`close] sess
              |`FinanceDept of 'c_FinanceDept * [`msg of unit data *
                [`send of [`FinanceDept of 'c_FinanceDept * [`getLoanAmount of int data *
                  [`recv of [`FinanceDept of 'c_FinanceDept * [`sendLoanAmount of int data *
                    [`send of [`Applicant of 'c_Applicant * [`requestConfirmation of int data *
                      [`close] sess]]] sess]]] sess]]] sess]]] sess]]] sess]]] sess]]] sess]]] sess]]]
type ('c_Applicant, 'c_ApplicationPortal, 'c_FinanceDept) bBSOriginal_ProcessingDept = ('c_Applicant, 'c_ApplicationPortal, 'c_FinanceDept) bBSOriginal_ProcessingDept_1
and ('c_Applicant, 'c_ApplicationPortal, 'c_FinanceDept) bBSOriginal_ProcessingDept_1 =
  [`accept of [`ApplicationPortal of 'c_ApplicationPortal * [`msg of unit data *
    [`recv of [`ApplicationPortal of 'c_ApplicationPortal * [`checkEligibility of (string * string * int * int) data *
      [`send of [`ApplicationPortal of 'c_ApplicationPortal * [`respond of bool data *
        [`close] sess]]] sess]]] sess]]]
type ('c_Applicant, 'c_ApplicationPortal, 'c_ProcessingDept) bBSOriginal_FinanceDept = ('c_Applicant, 'c_ApplicationPortal, 'c_ProcessingDept) bBSOriginal_FinanceDept_1
and ('c_Applicant, 'c_ApplicationPortal, 'c_ProcessingDept) bBSOriginal_FinanceDept_1 =
  [`accept of [`ApplicationPortal of 'c_ApplicationPortal * [`msg of unit data *
    [`recv of [`ApplicationPortal of 'c_ApplicationPortal * [`getLoanAmount of int data *
      [`send of [`ApplicationPortal of 'c_ApplicationPortal * [`sendLoanAmount of int data *
        [`close] sess]]] sess]]] sess]]]


module Shmem = Scribble.Shmem.Make(Session.LinIO.IO)(Session.Mutex)(Session.Condition)(Session.Endpoint)

type bBSOriginal = ShmemMPSTChanenl__ of Shmem.MPSTChannel.t
let create_shmem_channel : unit -> bBSOriginal = fun () ->
  ShmemMPSTChanenl__(Shmem.MPSTChannel.create ~acceptor_role:"role_Applicant" ~connector_roles:["role_ApplicationPortal";; "role_ProcessingDept"; "role_FinanceDept"])


module Applicant = struct
  let initiate : unit -> 'c. ('c, 'c, ('c_ApplicationPortal, 'c_ProcessingDept, 'c_FinanceDept) bBSOriginal_Applicant sess) monad =
    fun () -> Internal.__initiate ~myname:"role_Applicant"


  module ApplicationPortal = struct
    module Make(X:sig
        type conn
        val conn : conn Endpoint.conn_kind
        val write_msg : conn -> [>`msg of unit data * 'p sess] -> unit io
        val write_applyForLoan : conn -> [>`applyForLoan of (string * string * int * int) data * 'p sess] -> unit io
        val read_requestConfirmation_or_reject : conn -> [`requestConfirmation of int data * 'p0|`reject of unit data * 'p1] io
      end) = struct
      type conn = X.conn
      let role : ([>`ApplicationPortal of X.conn * 'lab], X.conn, 'lab) role =
        {_pack_role=(fun labels -> `ApplicationPortal(labels)) ; _repr="role_ApplicationPortal"; _kind=X.conn}

      let msg : 'p. ([>`msg of unit data * 'p sess], X.conn, unit data * 'p sess) label =
        {_pack_label=(fun payload -> `msg(payload)); _send=X.write_msg}
      let applyForLoan : 'p. ([>`applyForLoan of (string * string * int * int) data * 'p sess], X.conn, (string * string * int * int) data * 'p sess) label =
        {_pack_label=(fun payload -> `applyForLoan(payload)); _send=X.write_applyForLoan}
      let receive_requestConfirmation_or_reject  : type p0 p1. ([`requestConfirmation of int data * p0|`reject of unit data * p1], X.conn) labels =
        {_receive=X.read_requestConfirmation_or_reject}
    end

    module Raw = struct
      include Make(struct
          type conn = Shmem.Raw.t
          let conn = Shmem.MPSTChannel.Raw
          let write_msg = Shmem.Raw.send
          let write_applyForLoan = Shmem.Raw.send
          let read_requestConfirmation_or_reject = Shmem.Raw.receive
        end)
    end
  end
  module ProcessingDept = struct
    module Make(X:sig
        type conn
        val conn : conn Endpoint.conn_kind
      end) = struct
      type conn = X.conn
      let role : ([>`ProcessingDept of X.conn * 'lab], X.conn, 'lab) role =
        {_pack_role=(fun labels -> `ProcessingDept(labels)) ; _repr="role_ProcessingDept"; _kind=X.conn}

    end

    module Raw = struct
      include Make(struct
          type conn = Shmem.Raw.t
          let conn = Shmem.MPSTChannel.Raw
        end)
    end
  end
  module FinanceDept = struct
    module Make(X:sig
        type conn
        val conn : conn Endpoint.conn_kind
      end) = struct
      type conn = X.conn
      let role : ([>`FinanceDept of X.conn * 'lab], X.conn, 'lab) role =
        {_pack_role=(fun labels -> `FinanceDept(labels)) ; _repr="role_FinanceDept"; _kind=X.conn}

    end

    module Raw = struct
      include Make(struct
          type conn = Shmem.Raw.t
          let conn = Shmem.MPSTChannel.Raw
        end)
    end
  end

end

module ApplicationPortal = struct
  let initiate : unit -> 'c. ('c, 'c, ('c_Applicant, 'c_ProcessingDept, 'c_FinanceDept) bBSOriginal_ApplicationPortal sess) monad =
    fun () -> Internal.__initiate ~myname:"role_ApplicationPortal"


  module Applicant = struct
    module Make(X:sig
        type conn
        val conn : conn Endpoint.conn_kind
        val write_reject : conn -> [>`reject of unit data * 'p sess] -> unit io
        val write_requestConfirmation : conn -> [>`requestConfirmation of int data * 'p sess] -> unit io
        val read_msg : conn -> [`msg of unit data * 'p0] io
        val read_applyForLoan : conn -> [`applyForLoan of (string * string * int * int) data * 'p0] io
      end) = struct
      type conn = X.conn
      let role : ([>`Applicant of X.conn * 'lab], X.conn, 'lab) role =
        {_pack_role=(fun labels -> `Applicant(labels)) ; _repr="role_Applicant"; _kind=X.conn}

      let reject : 'p. ([>`reject of unit data * 'p sess], X.conn, unit data * 'p sess) label =
        {_pack_label=(fun payload -> `reject(payload)); _send=X.write_reject}
      let requestConfirmation : 'p. ([>`requestConfirmation of int data * 'p sess], X.conn, int data * 'p sess) label =
        {_pack_label=(fun payload -> `requestConfirmation(payload)); _send=X.write_requestConfirmation}
      let receive_msg  : type p0. ([`msg of unit data * p0], X.conn) labels =
        {_receive=X.read_msg}
      let receive_applyForLoan  : type p0. ([`applyForLoan of (string * string * int * int) data * p0], X.conn) labels =
        {_receive=X.read_applyForLoan}
    end

    module Raw = struct
      include Make(struct
          type conn = Shmem.Raw.t
          let conn = Shmem.MPSTChannel.Raw
          let write_reject = Shmem.Raw.send
          let write_requestConfirmation = Shmem.Raw.send
          let read_msg = Shmem.Raw.receive
          let read_applyForLoan = Shmem.Raw.receive
        end)
    end
  end
  module ProcessingDept = struct
    module Make(X:sig
        type conn
        val conn : conn Endpoint.conn_kind
        val write_msg : conn -> [>`msg of unit data * 'p sess] -> unit io
        val write_checkEligibility : conn -> [>`checkEligibility of (string * string * int * int) data * 'p sess] -> unit io
        val read_respond : conn -> [`respond of bool data * 'p0] io
      end) = struct
      type conn = X.conn
      let role : ([>`ProcessingDept of X.conn * 'lab], X.conn, 'lab) role =
        {_pack_role=(fun labels -> `ProcessingDept(labels)) ; _repr="role_ProcessingDept"; _kind=X.conn}

      let msg : 'p. ([>`msg of unit data * 'p sess], X.conn, unit data * 'p sess) label =
        {_pack_label=(fun payload -> `msg(payload)); _send=X.write_msg}
      let checkEligibility : 'p. ([>`checkEligibility of (string * string * int * int) data * 'p sess], X.conn, (string * string * int * int) data * 'p sess) label =
        {_pack_label=(fun payload -> `checkEligibility(payload)); _send=X.write_checkEligibility}
      let receive_respond  : type p0. ([`respond of bool data * p0], X.conn) labels =
        {_receive=X.read_respond}
    end

    module Raw = struct
      include Make(struct
          type conn = Shmem.Raw.t
          let conn = Shmem.MPSTChannel.Raw
          let write_msg = Shmem.Raw.send
          let write_checkEligibility = Shmem.Raw.send
          let read_respond = Shmem.Raw.receive
        end)
    end
  end
  module FinanceDept = struct
    module Make(X:sig
        type conn
        val conn : conn Endpoint.conn_kind
        val write_msg : conn -> [>`msg of unit data * 'p sess] -> unit io
        val write_getLoanAmount : conn -> [>`getLoanAmount of int data * 'p sess] -> unit io
        val read_sendLoanAmount : conn -> [`sendLoanAmount of int data * 'p0] io
      end) = struct
      type conn = X.conn
      let role : ([>`FinanceDept of X.conn * 'lab], X.conn, 'lab) role =
        {_pack_role=(fun labels -> `FinanceDept(labels)) ; _repr="role_FinanceDept"; _kind=X.conn}

      let msg : 'p. ([>`msg of unit data * 'p sess], X.conn, unit data * 'p sess) label =
        {_pack_label=(fun payload -> `msg(payload)); _send=X.write_msg}
      let getLoanAmount : 'p. ([>`getLoanAmount of int data * 'p sess], X.conn, int data * 'p sess) label =
        {_pack_label=(fun payload -> `getLoanAmount(payload)); _send=X.write_getLoanAmount}
      let receive_sendLoanAmount  : type p0. ([`sendLoanAmount of int data * p0], X.conn) labels =
        {_receive=X.read_sendLoanAmount}
    end

    module Raw = struct
      include Make(struct
          type conn = Shmem.Raw.t
          let conn = Shmem.MPSTChannel.Raw
          let write_msg = Shmem.Raw.send
          let write_getLoanAmount = Shmem.Raw.send
          let read_sendLoanAmount = Shmem.Raw.receive
        end)
    end
  end

end

module ProcessingDept = struct
  let initiate : unit -> 'c. ('c, 'c, ('c_Applicant, 'c_ApplicationPortal, 'c_FinanceDept) bBSOriginal_ProcessingDept sess) monad =
    fun () -> Internal.__initiate ~myname:"role_ProcessingDept"


  module Applicant = struct
    module Make(X:sig
        type conn
        val conn : conn Endpoint.conn_kind
      end) = struct
      type conn = X.conn
      let role : ([>`Applicant of X.conn * 'lab], X.conn, 'lab) role =
        {_pack_role=(fun labels -> `Applicant(labels)) ; _repr="role_Applicant"; _kind=X.conn}

    end

    module Raw = struct
      include Make(struct
          type conn = Shmem.Raw.t
          let conn = Shmem.MPSTChannel.Raw
        end)
    end
  end
  module ApplicationPortal = struct
    module Make(X:sig
        type conn
        val conn : conn Endpoint.conn_kind
        val write_respond : conn -> [>`respond of bool data * 'p sess] -> unit io
        val read_msg : conn -> [`msg of unit data * 'p0] io
        val read_checkEligibility : conn -> [`checkEligibility of (string * string * int * int) data * 'p0] io
      end) = struct
      type conn = X.conn
      let role : ([>`ApplicationPortal of X.conn * 'lab], X.conn, 'lab) role =
        {_pack_role=(fun labels -> `ApplicationPortal(labels)) ; _repr="role_ApplicationPortal"; _kind=X.conn}

      let respond : 'p. ([>`respond of bool data * 'p sess], X.conn, bool data * 'p sess) label =
        {_pack_label=(fun payload -> `respond(payload)); _send=X.write_respond}
      let receive_msg  : type p0. ([`msg of unit data * p0], X.conn) labels =
        {_receive=X.read_msg}
      let receive_checkEligibility  : type p0. ([`checkEligibility of (string * string * int * int) data * p0], X.conn) labels =
        {_receive=X.read_checkEligibility}
    end

    module Raw = struct
      include Make(struct
          type conn = Shmem.Raw.t
          let conn = Shmem.MPSTChannel.Raw
          let write_respond = Shmem.Raw.send
          let read_msg = Shmem.Raw.receive
          let read_checkEligibility = Shmem.Raw.receive
        end)
    end
  end
  module FinanceDept = struct
    module Make(X:sig
        type conn
        val conn : conn Endpoint.conn_kind
      end) = struct
      type conn = X.conn
      let role : ([>`FinanceDept of X.conn * 'lab], X.conn, 'lab) role =
        {_pack_role=(fun labels -> `FinanceDept(labels)) ; _repr="role_FinanceDept"; _kind=X.conn}

    end

    module Raw = struct
      include Make(struct
          type conn = Shmem.Raw.t
          let conn = Shmem.MPSTChannel.Raw
        end)
    end
  end

end

module FinanceDept = struct
  let initiate : unit -> 'c. ('c, 'c, ('c_Applicant, 'c_ApplicationPortal, 'c_ProcessingDept) bBSOriginal_FinanceDept sess) monad =
    fun () -> Internal.__initiate ~myname:"role_FinanceDept"


  module Applicant = struct
    module Make(X:sig
        type conn
        val conn : conn Endpoint.conn_kind
      end) = struct
      type conn = X.conn
      let role : ([>`Applicant of X.conn * 'lab], X.conn, 'lab) role =
        {_pack_role=(fun labels -> `Applicant(labels)) ; _repr="role_Applicant"; _kind=X.conn}

    end

    module Raw = struct
      include Make(struct
          type conn = Shmem.Raw.t
          let conn = Shmem.MPSTChannel.Raw
        end)
    end
  end
  module ApplicationPortal = struct
    module Make(X:sig
        type conn
        val conn : conn Endpoint.conn_kind
        val write_sendLoanAmount : conn -> [>`sendLoanAmount of int data * 'p sess] -> unit io
        val read_msg : conn -> [`msg of unit data * 'p0] io
        val read_getLoanAmount : conn -> [`getLoanAmount of int data * 'p0] io
      end) = struct
      type conn = X.conn
      let role : ([>`ApplicationPortal of X.conn * 'lab], X.conn, 'lab) role =
        {_pack_role=(fun labels -> `ApplicationPortal(labels)) ; _repr="role_ApplicationPortal"; _kind=X.conn}

      let sendLoanAmount : 'p. ([>`sendLoanAmount of int data * 'p sess], X.conn, int data * 'p sess) label =
        {_pack_label=(fun payload -> `sendLoanAmount(payload)); _send=X.write_sendLoanAmount}
      let receive_msg  : type p0. ([`msg of unit data * p0], X.conn) labels =
        {_receive=X.read_msg}
      let receive_getLoanAmount  : type p0. ([`getLoanAmount of int data * p0], X.conn) labels =
        {_receive=X.read_getLoanAmount}
    end

    module Raw = struct
      include Make(struct
          type conn = Shmem.Raw.t
          let conn = Shmem.MPSTChannel.Raw
          let write_sendLoanAmount = Shmem.Raw.send
          let read_msg = Shmem.Raw.receive
          let read_getLoanAmount = Shmem.Raw.receive
        end)
    end
  end
  module ProcessingDept = struct
    module Make(X:sig
        type conn
        val conn : conn Endpoint.conn_kind
      end) = struct
      type conn = X.conn
      let role : ([>`ProcessingDept of X.conn * 'lab], X.conn, 'lab) role =
        {_pack_role=(fun labels -> `ProcessingDept(labels)) ; _repr="role_ProcessingDept"; _kind=X.conn}

    end

    module Raw = struct
      include Make(struct
          type conn = Shmem.Raw.t
          let conn = Shmem.MPSTChannel.Raw
        end)
    end
  end

end

end