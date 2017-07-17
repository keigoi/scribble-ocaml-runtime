(* Generated from scribble-ocaml https://github.com/keigoi/scribble-ocaml
 * This code should be compiled with session-ocaml (multiparty)
 * https://github.com/keigoi/session-ocaml/tree/multiparty *)
open Multiparty
type buyerBrokerSupplier

type buyerBrokerSupplier_Applicant = buyerBrokerSupplier_Applicant_1
and buyerBrokerSupplier_Applicant_1 = 
  [`send of
    [`applyForLoan of [`ApplicationPortal] role * (string * string * int * int) data *
      [`recv of [`ApplicationPortal] role *
        [`requestConfirmation of int data *
          [`close] sess
        |`reject of unit data *
          [`close] sess]] sess]]
type buyerBrokerSupplier_ApplicationPortal = buyerBrokerSupplier_ApplicationPortal_1
and buyerBrokerSupplier_ApplicationPortal_1 = 
  [`recv of [`Applicant] role * [`applyForLoan of (string * string * int * int) data *
    [`send of
      [`checkEligibility of [`ProcessingDept] role * (string * string * int * int) data *
        [`recv of [`ProcessingDept] role * [`respond of bool data *
          [`send of
            [`getLoanAmount of [`FinanceDept] role * int data *
              [`recv of [`FinanceDept] role * [`sendLoanAmount of int data *
                [`send of
                  [`requestConfirmation of [`Applicant] role * int data *
                    [`close] sess]] sess]] sess
            |`reject of [`FinanceDept] role * unit data *
              [`send of
                [`reject of [`Applicant] role * unit data *
                  [`close] sess]] sess]] sess]] sess]] sess]]
type buyerBrokerSupplier_ProcessingDept = buyerBrokerSupplier_ProcessingDept_1
and buyerBrokerSupplier_ProcessingDept_1 = 
  [`recv of [`ApplicationPortal] role * [`checkEligibility of (string * string * int * int) data *
    [`send of
      [`respond of [`ApplicationPortal] role * bool data *
        [`close] sess]] sess]]
type buyerBrokerSupplier_FinanceDept = buyerBrokerSupplier_FinanceDept_1
and buyerBrokerSupplier_FinanceDept_1 = 
  [`recv of [`ApplicationPortal] role *
    [`getLoanAmount of int data *
      [`send of
        [`sendLoanAmount of [`ApplicationPortal] role * int data *
          [`close] sess]] sess
    |`reject of unit data *
      [`close] sess]]

let role_Applicant : [`Applicant] role = Internal.__mkrole "buyerBrokerSupplier_Applicant"
let role_ApplicationPortal : [`ApplicationPortal] role = Internal.__mkrole "buyerBrokerSupplier_ApplicationPortal"
let role_ProcessingDept : [`ProcessingDept] role = Internal.__mkrole "buyerBrokerSupplier_ProcessingDept"
let role_FinanceDept : [`FinanceDept] role = Internal.__mkrole "buyerBrokerSupplier_FinanceDept"

let accept_Applicant : 'pre 'post. (buyerBrokerSupplier,[`ConnectFirst]) channel -> bindto:(empty, buyerBrokerSupplier_Applicant sess, 'pre, 'post) slot -> ('pre,'post,unit) monad =
  fun ch ->
  Internal.__accept ~myname:"buyerBrokerSupplier_Applicant" ~cli_count:3 ch

let connect_ApplicationPortal : 'pre 'post. (buyerBrokerSupplier,[`ConnectFirst]) channel -> bindto:(empty, buyerBrokerSupplier_ApplicationPortal sess, 'pre, 'post) slot -> ('pre,'post,unit) monad =
  fun ch ->
  Internal.__connect ~myname:"buyerBrokerSupplier_ApplicationPortal" ch
let connect_ProcessingDept : 'pre 'post. (buyerBrokerSupplier,[`ConnectFirst]) channel -> bindto:(empty, buyerBrokerSupplier_ProcessingDept sess, 'pre, 'post) slot -> ('pre,'post,unit) monad =
  fun ch ->
  Internal.__connect ~myname:"buyerBrokerSupplier_ProcessingDept" ch
let connect_FinanceDept : 'pre 'post. (buyerBrokerSupplier,[`ConnectFirst]) channel -> bindto:(empty, buyerBrokerSupplier_FinanceDept sess, 'pre, 'post) slot -> ('pre,'post,unit) monad =
  fun ch ->
  Internal.__connect ~myname:"buyerBrokerSupplier_FinanceDept" ch

let new_channel_buyerBrokerSupplier : unit -> (buyerBrokerSupplier,[`ConnectFirst]) channel = new_channel
let msg_checkEligibility = {_pack=(fun a -> `checkEligibility(a))}
let msg_reject = {_pack=(fun a -> `reject(a))}
let msg_sendLoanAmount = {_pack=(fun a -> `sendLoanAmount(a))}
let msg_getLoanAmount = {_pack=(fun a -> `getLoanAmount(a))}
let msg_requestConfirmation = {_pack=(fun a -> `requestConfirmation(a))}
let msg_respond = {_pack=(fun a -> `respond(a))}
let msg_applyForLoan = {_pack=(fun a -> `applyForLoan(a))}
