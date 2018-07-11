(* Generated from scribble-ocaml https://github.com/keigoi/scribble-ocaml
 * This code should be compiled with scribble-ocaml-runtime
 * https://github.com/keigoi/scribble-ocaml-runtime *)


module Make (Session:Scribble.S.SESSION)  = struct
  type int = java.lang.Integer
  type string = java.lang.String
  type bool = java.lang.Boolean

open Session

type ('c_ApplicationPortal, 'c_ProcessingDept, 'c_FinanceDept) buyerBrokerSupplier_Applicant = ('c_ApplicationPortal, 'c_ProcessingDept, 'c_FinanceDept) buyerBrokerSupplier_Applicant_1
and ('c_ApplicationPortal, 'c_ProcessingDept, 'c_FinanceDept) buyerBrokerSupplier_Applicant_1 =
  [`send of [`ApplicationPortal of 'c_ApplicationPortal * [`applyForLoan of (string * string * int * int) data *
    [`recv of [`ApplicationPortal of 'c_ApplicationPortal *
      [`requestConfirmation of int data *
        [`close] sess
      |`reject of unit data *
        [`close] sess]]] sess]]]
type ('c_Applicant, 'c_ProcessingDept, 'c_FinanceDept) buyerBrokerSupplier_ApplicationPortal = ('c_Applicant, 'c_ProcessingDept, 'c_FinanceDept) buyerBrokerSupplier_ApplicationPortal_1
and ('c_Applicant, 'c_ProcessingDept, 'c_FinanceDept) buyerBrokerSupplier_ApplicationPortal_1 =
  [`recv of [`Applicant of 'c_Applicant * [`applyForLoan of (string * string * int * int) data *
    [`send of [`ProcessingDept of 'c_ProcessingDept * [`checkEligibility of (string * string * int * int) data *
      [`recv of [`ProcessingDept of 'c_ProcessingDept * [`respond of bool data *
        [`send of [`FinanceDept of 'c_FinanceDept *
          [`getLoanAmount of int data *
            [`recv of [`FinanceDept of 'c_FinanceDept * [`sendLoanAmount of int data *
              [`send of [`Applicant of 'c_Applicant * [`requestConfirmation of int data *
                [`close] sess]]] sess]]] sess
          |`reject of unit data *
            [`send of [`Applicant of 'c_Applicant * [`reject of unit data *
              [`close] sess]]] sess]]] sess]]] sess]]] sess]]]
type ('c_Applicant, 'c_ApplicationPortal, 'c_FinanceDept) buyerBrokerSupplier_ProcessingDept = ('c_Applicant, 'c_ApplicationPortal, 'c_FinanceDept) buyerBrokerSupplier_ProcessingDept_1
and ('c_Applicant, 'c_ApplicationPortal, 'c_FinanceDept) buyerBrokerSupplier_ProcessingDept_1 =
  [`recv of [`ApplicationPortal of 'c_ApplicationPortal * [`checkEligibility of (string * string * int * int) data *
    [`send of [`ApplicationPortal of 'c_ApplicationPortal * [`respond of bool data *
      [`close] sess]]] sess]]]
type ('c_Applicant, 'c_ApplicationPortal, 'c_ProcessingDept) buyerBrokerSupplier_FinanceDept = ('c_Applicant, 'c_ApplicationPortal, 'c_ProcessingDept) buyerBrokerSupplier_FinanceDept_1
and ('c_Applicant, 'c_ApplicationPortal, 'c_ProcessingDept) buyerBrokerSupplier_FinanceDept_1 =
  [`recv of [`ApplicationPortal of 'c_ApplicationPortal *
    [`getLoanAmount of int data *
      [`send of [`ApplicationPortal of 'c_ApplicationPortal * [`sendLoanAmount of int data *
        [`close] sess]]] sess
    |`reject of unit data *
      [`close] sess]]]


module Shmem = Scribble.Shmem.Make(Session.LinIO.IO)(Session.Mutex)(Session.Condition)(Session.Endpoint)

type buyerBrokerSupplier = ShmemMPSTChanenl__ of Shmem.MPSTChannel.t
let create_shmem_channel : unit -> buyerBrokerSupplier = fun () ->
  ShmemMPSTChanenl__(Shmem.MPSTChannel.create ~acceptor_role:"role_Applicant" ~connector_roles:["role_ApplicationPortal";; "role_ProcessingDept"; "role_FinanceDept"])


module Applicant = struct
  let initiate_shmem : 'c. buyerBrokerSupplier -> ('c, 'c, Shmem.Raw.t buyerBrokerSupplier_Applicant sess) monad = fun (ShmemMPSTChanenl__(c)) ->
    Internal.__start (Shmem.MPSTChannel.accept c ~role:"role_Applicant")

  module ApplicationPortal = struct
    module Make(X:sig
        type conn
        val conn : conn Endpoint.conn_kind
        val write_applyForLoan : conn -> [>`applyForLoan of (string * string * int * int) data * 'p sess] -> unit io
        val read_requestConfirmation_or_reject : conn -> [`requestConfirmation of int data * 'p0|`reject of unit data * 'p1] io
      end) = struct
      type conn = X.conn
      let role : ([>`ApplicationPortal of X.conn * 'lab], X.conn, 'lab) role =
        {_pack_role=(fun labels -> `ApplicationPortal(labels)) ; _repr="role_ApplicationPortal"; _kind=X.conn}

      let applyForLoan : 'p. ([>`applyForLoan of (string * string * int * int) data * 'p sess], X.conn, (string * string * int * int) data * 'p sess) label =
        {_pack_label=(fun payload -> `applyForLoan(payload)); _send=X.write_applyForLoan}
      let receive_requestConfirmation_or_reject  : type p0 p1. ([`requestConfirmation of int data * p0|`reject of unit data * p1], X.conn) labels =
        {_receive=X.read_requestConfirmation_or_reject}
    end

    module Raw = struct
      include Make(struct
          type conn = Shmem.Raw.t
          let conn = Shmem.MPSTChannel.Raw
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
  let initiate_shmem : 'c. buyerBrokerSupplier -> ('c, 'c, Shmem.Raw.t buyerBrokerSupplier_ApplicationPortal sess) monad = fun (ShmemMPSTChanenl__(c)) ->
    Internal.__start (Shmem.MPSTChannel.connect c ~role:"role_ApplicationPortal")

  module Applicant = struct
    module Make(X:sig
        type conn
        val conn : conn Endpoint.conn_kind
        val write_requestConfirmation : conn -> [>`requestConfirmation of int data * 'p sess] -> unit io
        val write_reject : conn -> [>`reject of unit data * 'p sess] -> unit io
        val read_applyForLoan : conn -> [`applyForLoan of (string * string * int * int) data * 'p0] io
      end) = struct
      type conn = X.conn
      let role : ([>`Applicant of X.conn * 'lab], X.conn, 'lab) role =
        {_pack_role=(fun labels -> `Applicant(labels)) ; _repr="role_Applicant"; _kind=X.conn}

      let requestConfirmation : 'p. ([>`requestConfirmation of int data * 'p sess], X.conn, int data * 'p sess) label =
        {_pack_label=(fun payload -> `requestConfirmation(payload)); _send=X.write_requestConfirmation}
      let reject : 'p. ([>`reject of unit data * 'p sess], X.conn, unit data * 'p sess) label =
        {_pack_label=(fun payload -> `reject(payload)); _send=X.write_reject}
      let receive_applyForLoan  : type p0. ([`applyForLoan of (string * string * int * int) data * p0], X.conn) labels =
        {_receive=X.read_applyForLoan}
    end

    module Raw = struct
      include Make(struct
          type conn = Shmem.Raw.t
          let conn = Shmem.MPSTChannel.Raw
          let write_requestConfirmation = Shmem.Raw.send
          let write_reject = Shmem.Raw.send
          let read_applyForLoan = Shmem.Raw.receive
        end)
    end
  end
  module ProcessingDept = struct
    module Make(X:sig
        type conn
        val conn : conn Endpoint.conn_kind
        val write_checkEligibility : conn -> [>`checkEligibility of (string * string * int * int) data * 'p sess] -> unit io
        val read_respond : conn -> [`respond of bool data * 'p0] io
      end) = struct
      type conn = X.conn
      let role : ([>`ProcessingDept of X.conn * 'lab], X.conn, 'lab) role =
        {_pack_role=(fun labels -> `ProcessingDept(labels)) ; _repr="role_ProcessingDept"; _kind=X.conn}

      let checkEligibility : 'p. ([>`checkEligibility of (string * string * int * int) data * 'p sess], X.conn, (string * string * int * int) data * 'p sess) label =
        {_pack_label=(fun payload -> `checkEligibility(payload)); _send=X.write_checkEligibility}
      let receive_respond  : type p0. ([`respond of bool data * p0], X.conn) labels =
        {_receive=X.read_respond}
    end

    module Raw = struct
      include Make(struct
          type conn = Shmem.Raw.t
          let conn = Shmem.MPSTChannel.Raw
          let write_checkEligibility = Shmem.Raw.send
          let read_respond = Shmem.Raw.receive
        end)
    end
  end
  module FinanceDept = struct
    module Make(X:sig
        type conn
        val conn : conn Endpoint.conn_kind
        val write_getLoanAmount : conn -> [>`getLoanAmount of int data * 'p sess] -> unit io
        val write_reject : conn -> [>`reject of unit data * 'p sess] -> unit io
        val read_sendLoanAmount : conn -> [`sendLoanAmount of int data * 'p0] io
      end) = struct
      type conn = X.conn
      let role : ([>`FinanceDept of X.conn * 'lab], X.conn, 'lab) role =
        {_pack_role=(fun labels -> `FinanceDept(labels)) ; _repr="role_FinanceDept"; _kind=X.conn}

      let getLoanAmount : 'p. ([>`getLoanAmount of int data * 'p sess], X.conn, int data * 'p sess) label =
        {_pack_label=(fun payload -> `getLoanAmount(payload)); _send=X.write_getLoanAmount}
      let reject : 'p. ([>`reject of unit data * 'p sess], X.conn, unit data * 'p sess) label =
        {_pack_label=(fun payload -> `reject(payload)); _send=X.write_reject}
      let receive_sendLoanAmount  : type p0. ([`sendLoanAmount of int data * p0], X.conn) labels =
        {_receive=X.read_sendLoanAmount}
    end

    module Raw = struct
      include Make(struct
          type conn = Shmem.Raw.t
          let conn = Shmem.MPSTChannel.Raw
          let write_getLoanAmount = Shmem.Raw.send
          let write_reject = Shmem.Raw.send
          let read_sendLoanAmount = Shmem.Raw.receive
        end)
    end
  end

end

module ProcessingDept = struct
  let initiate_shmem : 'c. buyerBrokerSupplier -> ('c, 'c, Shmem.Raw.t buyerBrokerSupplier_ProcessingDept sess) monad = fun (ShmemMPSTChanenl__(c)) ->
    Internal.__start (Shmem.MPSTChannel.connect c ~role:"role_ProcessingDept")

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
        val read_checkEligibility : conn -> [`checkEligibility of (string * string * int * int) data * 'p0] io
      end) = struct
      type conn = X.conn
      let role : ([>`ApplicationPortal of X.conn * 'lab], X.conn, 'lab) role =
        {_pack_role=(fun labels -> `ApplicationPortal(labels)) ; _repr="role_ApplicationPortal"; _kind=X.conn}

      let respond : 'p. ([>`respond of bool data * 'p sess], X.conn, bool data * 'p sess) label =
        {_pack_label=(fun payload -> `respond(payload)); _send=X.write_respond}
      let receive_checkEligibility  : type p0. ([`checkEligibility of (string * string * int * int) data * p0], X.conn) labels =
        {_receive=X.read_checkEligibility}
    end

    module Raw = struct
      include Make(struct
          type conn = Shmem.Raw.t
          let conn = Shmem.MPSTChannel.Raw
          let write_respond = Shmem.Raw.send
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
  let initiate_shmem : 'c. buyerBrokerSupplier -> ('c, 'c, Shmem.Raw.t buyerBrokerSupplier_FinanceDept sess) monad = fun (ShmemMPSTChanenl__(c)) ->
    Internal.__start (Shmem.MPSTChannel.connect c ~role:"role_FinanceDept")

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
        val read_getLoanAmount_or_reject : conn -> [`getLoanAmount of int data * 'p0|`reject of unit data * 'p1] io
      end) = struct
      type conn = X.conn
      let role : ([>`ApplicationPortal of X.conn * 'lab], X.conn, 'lab) role =
        {_pack_role=(fun labels -> `ApplicationPortal(labels)) ; _repr="role_ApplicationPortal"; _kind=X.conn}

      let sendLoanAmount : 'p. ([>`sendLoanAmount of int data * 'p sess], X.conn, int data * 'p sess) label =
        {_pack_label=(fun payload -> `sendLoanAmount(payload)); _send=X.write_sendLoanAmount}
      let receive_getLoanAmount_or_reject  : type p0 p1. ([`getLoanAmount of int data * p0|`reject of unit data * p1], X.conn) labels =
        {_receive=X.read_getLoanAmount_or_reject}
    end

    module Raw = struct
      include Make(struct
          type conn = Shmem.Raw.t
          let conn = Shmem.MPSTChannel.Raw
          let write_sendLoanAmount = Shmem.Raw.send
          let read_getLoanAmount_or_reject = Shmem.Raw.receive
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