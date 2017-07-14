(* Generated from scribble-ocaml https://github.com/keigoi/scribble-ocaml
 * This code should be compiled with session-ocaml (multiparty)
 * https://github.com/keigoi/session-ocaml/tree/multiparty *)
open Multiparty
type bBSOriginal

type bBSOriginal_Applicant = bBSOriginal_Applicant_1
and bBSOriginal_Applicant_1 = 
  [`send of
    [`msg of [`ApplicationPortal] role connect * unit *
      [`send of
        [`applyForLoan of [`ApplicationPortal] role * (string * string * int * int) *
          [`recv of
            [`requestConfirmation of [`ApplicationPortal] role * int *
              [`close]
            |`reject of [`ApplicationPortal] role * unit *
              [`close]]]]]]]
type bBSOriginal_ApplicationPortal = bBSOriginal_ApplicationPortal_1
and bBSOriginal_ApplicationPortal_1 = 
  [`accept of
    [`msg of [`Applicant] role * unit *
      [`send of
        [`msg of [`ProcessingDept] role connect * unit *
          [`recv of [`applyForLoan of [`Applicant] role * (string * string * int * int) *
            [`send of
              [`checkEligibility of [`ProcessingDept] role * (string * string * int * int) *
                [`recv of [`respond of [`ProcessingDept] role * bool *
                  [`send of
                    [`msg of [`FinanceDept] role connect * unit *
                      [`send of
                        [`getLoanAmount of [`FinanceDept] role * int *
                          [`recv of [`sendLoanAmount of [`FinanceDept] role * int *
                            [`send of
                              [`requestConfirmation of [`Applicant] role * int *
                                [`close]]]]]]]
                    |`reject of [`Applicant] role * unit *
                      [`close]]]]]]]]]]]]]
type bBSOriginal_ProcessingDept = bBSOriginal_ProcessingDept_1
and bBSOriginal_ProcessingDept_1 = 
  [`accept of
    [`msg of [`ApplicationPortal] role * unit *
      [`recv of [`checkEligibility of [`ApplicationPortal] role * (string * string * int * int) *
        [`send of
          [`respond of [`ApplicationPortal] role * bool *
            [`close]]]]]]]
type bBSOriginal_FinanceDept = bBSOriginal_FinanceDept_1
and bBSOriginal_FinanceDept_1 = 
  [`accept of
    [`msg of [`ApplicationPortal] role * unit *
      [`recv of [`getLoanAmount of [`ApplicationPortal] role * int *
        [`send of
          [`sendLoanAmount of [`ApplicationPortal] role * int *
            [`close]]]]]]]

let role_Applicant : [`Applicant] role = Internal.__mkrole "bBSOriginal_Applicant"
let role_ApplicationPortal : [`ApplicationPortal] role = Internal.__mkrole "bBSOriginal_ApplicationPortal"
let role_ProcessingDept : [`ProcessingDept] role = Internal.__mkrole "bBSOriginal_ProcessingDept"
let role_FinanceDept : [`FinanceDept] role = Internal.__mkrole "bBSOriginal_FinanceDept"

let initiate_Applicant : 'pre 'post. (bBSOriginal,[`ConnectLater]) channel -> bindto:(empty, bBSOriginal_Applicant sess, 'pre, 'post) slot -> ('pre,'post,unit) monad =
  fun ch ->
  Internal.__initiate ~myname:"bBSOriginal_Applicant" ch
let initiate_ApplicationPortal : 'pre 'post. (bBSOriginal,[`ConnectLater]) channel -> bindto:(empty, bBSOriginal_ApplicationPortal sess, 'pre, 'post) slot -> ('pre,'post,unit) monad =
  fun ch ->
  Internal.__initiate ~myname:"bBSOriginal_ApplicationPortal" ch
let initiate_ProcessingDept : 'pre 'post. (bBSOriginal,[`ConnectLater]) channel -> bindto:(empty, bBSOriginal_ProcessingDept sess, 'pre, 'post) slot -> ('pre,'post,unit) monad =
  fun ch ->
  Internal.__initiate ~myname:"bBSOriginal_ProcessingDept" ch
let initiate_FinanceDept : 'pre 'post. (bBSOriginal,[`ConnectLater]) channel -> bindto:(empty, bBSOriginal_FinanceDept sess, 'pre, 'post) slot -> ('pre,'post,unit) monad =
  fun ch ->
  Internal.__initiate ~myname:"bBSOriginal_FinanceDept" ch

let new_channel_bBSOriginal () : (bBSOriginal,[`ConnectLater]) channel = Internal.__new_connect_later_channel ["bBSOriginal_Applicant";"bBSOriginal_ApplicationPortal";"bBSOriginal_ProcessingDept";"bBSOriginal_FinanceDept"]
let msg_none = {_pack=(fun a -> `msg(a))}
let msg_checkEligibility = {_pack=(fun a -> `checkEligibility(a))}
let msg_reject = {_pack=(fun a -> `reject(a))}
let msg_sendLoanAmount = {_pack=(fun a -> `sendLoanAmount(a))}
let msg_getLoanAmount = {_pack=(fun a -> `getLoanAmount(a))}
let msg_requestConfirmation = {_pack=(fun a -> `requestConfirmation(a))}
let msg_respond = {_pack=(fun a -> `respond(a))}
let msg_applyForLoan = {_pack=(fun a -> `applyForLoan(a))}
