(* Generated from scribble-ocaml https://github.com/keigoi/scribble-ocaml
 * This code should be compiled with scribble-ocaml-runtime
 * https://github.com/keigoi/scribble-ocaml-runtime *)
open Multiparty
type bBSOriginal

type bBSOriginal_Applicant = bBSOriginal_Applicant_1
and bBSOriginal_Applicant_1 = 
  [`send of
    [`msg of [`ApplicationPortal] role connect * unit data *
      [`send of
        [`applyForLoan of [`ApplicationPortal] role * (string * string * int * int) data *
          [`recv of [`ApplicationPortal] role *
            [`requestConfirmation of int data *
              [`close] sess
            |`reject of unit data *
              [`close] sess]] sess]] sess]]
type bBSOriginal_ApplicationPortal = bBSOriginal_ApplicationPortal_1
and bBSOriginal_ApplicationPortal_1 = 
  [`accept of [`Applicant] role *
    [`msg of unit data *
      [`send of
        [`msg of [`ProcessingDept] role connect * unit data *
          [`recv of [`Applicant] role * [`applyForLoan of (string * string * int * int) data *
            [`send of
              [`checkEligibility of [`ProcessingDept] role * (string * string * int * int) data *
                [`recv of [`ProcessingDept] role * [`respond of bool data *
                  [`send of
                    [`msg of [`FinanceDept] role connect * unit data *
                      [`send of
                        [`getLoanAmount of [`FinanceDept] role * int data *
                          [`recv of [`FinanceDept] role * [`sendLoanAmount of int data *
                            [`send of
                              [`requestConfirmation of [`Applicant] role * int data *
                                [`close] sess]] sess]] sess]] sess
                    |`reject of [`Applicant] role * unit data *
                      [`close] sess]] sess]] sess]] sess]] sess]] sess]]
type bBSOriginal_ProcessingDept = bBSOriginal_ProcessingDept_1
and bBSOriginal_ProcessingDept_1 = 
  [`accept of [`ApplicationPortal] role *
    [`msg of unit data *
      [`recv of [`ApplicationPortal] role * [`checkEligibility of (string * string * int * int) data *
        [`send of
          [`respond of [`ApplicationPortal] role * bool data *
            [`close] sess]] sess]] sess]]
type bBSOriginal_FinanceDept = bBSOriginal_FinanceDept_1
and bBSOriginal_FinanceDept_1 = 
  [`accept of [`ApplicationPortal] role *
    [`msg of unit data *
      [`recv of [`ApplicationPortal] role * [`getLoanAmount of int data *
        [`send of
          [`sendLoanAmount of [`ApplicationPortal] role * int data *
            [`close] sess]] sess]] sess]]

let role_Applicant : [`Applicant] role = Internal.__mkrole "role_Applicant"
let role_ApplicationPortal : [`ApplicationPortal] role = Internal.__mkrole "role_ApplicationPortal"
let role_ProcessingDept : [`ProcessingDept] role = Internal.__mkrole "role_ProcessingDept"
let role_FinanceDept : [`FinanceDept] role = Internal.__mkrole "role_FinanceDept"

let initiate_Applicant : 'pre 'post. (bBSOriginal,[`Explicit]) channel -> ('c, 'c, bBSOriginal_Applicant sess) monad =
  fun ch ->
  Internal.__initiate ~myname:"role_Applicant" ch
let initiate_ApplicationPortal : 'pre 'post. (bBSOriginal,[`Explicit]) channel -> ('c, 'c, bBSOriginal_ApplicationPortal sess) monad =
  fun ch ->
  Internal.__initiate ~myname:"role_ApplicationPortal" ch
let initiate_ProcessingDept : 'pre 'post. (bBSOriginal,[`Explicit]) channel -> ('c, 'c, bBSOriginal_ProcessingDept sess) monad =
  fun ch ->
  Internal.__initiate ~myname:"role_ProcessingDept" ch
let initiate_FinanceDept : 'pre 'post. (bBSOriginal,[`Explicit]) channel -> ('c, 'c, bBSOriginal_FinanceDept sess) monad =
  fun ch ->
  Internal.__initiate ~myname:"role_FinanceDept" ch

let new_channel_bBSOriginal () : (bBSOriginal,[`Explicit]) channel = Internal.__new_connect_later_channel ["role_Applicant";"role_ApplicationPortal";"role_ProcessingDept";"role_FinanceDept"]
let msg_none = {_pack=(fun a -> `msg(a))}
let msg_applyForLoan = {_pack=(fun a -> `applyForLoan(a))}
let msg_checkEligibility = {_pack=(fun a -> `checkEligibility(a))}
let msg_getLoanAmount = {_pack=(fun a -> `getLoanAmount(a))}
let msg_reject = {_pack=(fun a -> `reject(a))}
let msg_requestConfirmation = {_pack=(fun a -> `requestConfirmation(a))}
let msg_respond = {_pack=(fun a -> `respond(a))}
let msg_sendLoanAmount = {_pack=(fun a -> `sendLoanAmount(a))}
