open Ast_helper
open Asttypes
open Parsetree
open Longident
open Ast_convenience

let newname prefix i =
  Printf.sprintf "__ppx_session_%s_%d" prefix i

let freshname =
  let r = ref 0 in
  fun () ->
    let i = !r in
    r := i + 1;
    Printf.sprintf "ppx_session_var_%d" i
  
let root_module = ref "Session.Syntax"

let longident str = Exp.ident (lid str)

let monad_bind () =
  longident (!root_module ^ ".>>=")

let error loc (s:string) = 
  Location.raise_errorf ~loc "%s" s
  
(* [?? = e0] and [?? = e1] and .. ==> [dum$0 = e0] and [dum$1 = e1] and .. 
   (to use with bindbody_of_let.) *)
let bindings_of_let bindings =
  List.mapi (fun i binding ->
      {binding with pvb_pat = pvar (newname "let" i)}
    ) bindings

(* [p0 = ??] and [p1 = ??] and .. and e ==> [bind dum$0 (fun p0 -> bind dum$1 (fun p1 -> .. -> e))] *)
let bindbody_of_let exploc bindings exp =
  let rec make i bindings =
    match bindings with
    | [] -> exp
    | binding :: t ->
      let name = (evar (newname "let" i)) [@metaloc binding.pvb_expr.pexp_loc] in
      let f = [%expr (fun [%p binding.pvb_pat] -> [%e make (i+1) t])] [@metaloc binding.pvb_loc] in
      let new_exp = [%expr [%e monad_bind ()] [%e name] [%e f]] [@metaloc exploc] in
      { new_exp with pexp_attributes = binding.pvb_attributes }
  in
  make 0 bindings

(* [{lab1} = e1] and [{lab2} = e2 and .. and e ==> e1 ~bindto:lab1 >>= (fun () -> e2 ~bindto:lab2 ]  *)
(* [#lab1 = e1] and [#lab2 = e2 and .. and e ==> e1 ~bindto:lab1 >>= (fun () -> e2 ~bindto:lab2 ]  *)
let slot_bind bindings expr =
  let f binding expr =
    match binding with
    | {pvb_pat = {ppat_desc = Ppat_record ([({txt},_)],Closed)}; pvb_expr = rhs}
    | {pvb_pat = {ppat_desc = Ppat_type {txt}}; pvb_expr = rhs} ->
      let lensname = String.concat "." (Longident.flatten txt) in
      let f = Exp.fun_ Label.nolabel None (punit ()) expr in
      [%expr [%e monad_bind ()] ([%e rhs] ~bindto:[%e evar lensname]) [%e f]]
    | _ -> raise Not_found
  in List.fold_right f bindings expr
  
(* Converts match clauses to handle branching.
  | `lab1(pat) -> e1
  | ..
  | `labN(pat) -> eN
  ==> 
  | `lab1((_:'a),p,q),r -> __set e00 (q,r) >> e1 
  | ..
  | `labN((_:'a),p,q),r -> __set e00 (q,r) >> eN)
  : [`lab1 of 'x * 'v1 * 'p1 | .. | `labN of 'x * 'vN * 'pN] -> 'b)
*)
let session_branch_clauses e_slot cases typvar_dir =
  let branch_exp = [%expr [%e longident (!root_module ^ ".SessionN.__set")] [%e e_slot]]
  in
  let conv = function
    | {pc_lhs={ppat_desc=Ppat_variant(labl,Some(pat));ppat_loc;ppat_attributes};pc_guard;pc_rhs=rhs_orig} ->
       let protocol_var1 = newname "match_p" 0 in
       let protocol_var2 = newname "match_q" 0 in
       let pat = [%pat? ( [%p Pat.variant labl (Some(ptuple [Pat.constraint_ (Pat.any()) typvar_dir;pat;pvar protocol_var1])) ], [%p pvar protocol_var2])] in
       let pair = [%expr [%e evar protocol_var1],[%e evar protocol_var2]] in
       let expr = [%expr [%e monad_bind ()] ([%e branch_exp] [%e pair]) (fun () -> [%e rhs_orig])] in
       {pc_lhs={ppat_desc=pat.ppat_desc;ppat_loc;ppat_attributes};pc_guard;pc_rhs=expr}, labl
    | {pc_lhs={ppat_loc=loc}} -> error loc "Invalid pattern"
  in
  List.split (List.map conv cases)

let branch_func_name funname = longident (!root_module ^ ".SessionN.__"^funname)

let make_branch_func_types labls =
  let open Typ in
  let rows =
    List.mapi (fun i labl -> Rtag(labl,[],false,[var (freshname ())])) labls
  in
  [%type: [%t (variant rows Closed None)] * [%t var (freshname ())] -> [%t var (freshname ())] ]

let expression_mapper id mapper exp attrs =
  let pexp_attributes = attrs @ exp.pexp_attributes in
  let pexp_loc=exp.pexp_loc in
  match id, exp.pexp_desc with

  (* monadic bind *)
  (* let%s p = e1 in e2 ==> let dum$0 = e1 in Session.(>>=) dum$0 e2 *)
  | ("s"|"w"), Pexp_let (Nonrecursive, vbl, expression) ->
      let new_exp =
        Exp.let_
          Nonrecursive
          (bindings_of_let vbl)
          (bindbody_of_let exp.pexp_loc vbl expression)
      in
      Some (mapper.Ast_mapper.expr mapper { new_exp with pexp_attributes })
  | ("s"|"w"), _ -> error pexp_loc "Invalid content for extension %s|%w"

  (* slot bind *)
  (* let%lin {lab} = e1 in e2 ==> Session.(>>=) (e1 ~bindto:lab) (fun () -> e2) *)
  | "slot", Pexp_let (Nonrecursive, vbl, expression) ->
      let new_exp = slot_bind vbl expression in
      Some (mapper.Ast_mapper.expr mapper { new_exp with pexp_attributes })
  | "slot", _ -> error pexp_loc "Invalid content for extension %lin"

  (*
  match%branch e00 e01 with | `lab1 -> e1 | .. | `labN -> eN
  ==>
  __receive e00 (e01:'a) >>= ((function
     | `lab1((_:'a),p,q),r -> __set e00 (q,r) >> e1 | ..
     | `labN((_:'a),p,q),r -> __set e00 (q,r) >> eN)
     : [`lab1 of 'p1 | .. | `labN of 'pN] * 'a -> 'b)
  *)
  | "label", Pexp_match ({pexp_desc=Pexp_apply({pexp_desc=Pexp_ident({txt=Lident funname})},[(_,e_slot);(_,e_dir)])}, cases) ->
     let open Typ in
     let typvar_dir = Typ.var (freshname ()) in
     let cases, labls = session_branch_clauses e_slot cases typvar_dir in
     let new_typ = make_branch_func_types labls in
     let new_exp =
       [%expr [%e branch_func_name funname] [%e e_slot] ([%e e_dir] : [%t typvar_dir]) >>=
              ([%e Exp.function_ cases] : [%t new_typ ])]
    in
    Some (mapper.Ast_mapper.expr mapper {new_exp with pexp_attributes})
  | "label", _ -> error pexp_loc "Invalid content for extension %label; it must be match%label slot dir receive or match%label accept slot dir"

  | _ -> None

let rebind_module modexpr =
  match modexpr.pmod_desc with
  | Pmod_ident {txt = id} -> root_module := String.concat "." (Longident.flatten id)
  | _ -> error modexpr.pmod_loc "Use (module M) here."
  
let runner ({ ptype_loc = loc } as type_decl) =
  match type_decl with
  (* | {ptype_kind = Ptype_record labels} -> *)
  | {ptype_name = {txt = name}; ptype_manifest = Some ({ptyp_desc = Ptyp_object (labels, Closed)})} ->
    let obj = 
      let meth (fname,_,_) =
        {pcf_desc =
           Pcf_method ({txt=fname;loc=Location.none},
                       Public,
                       Cfk_concrete(Fresh, [%expr Multiparty.Empty]));
         pcf_loc = Location.none;
         pcf_attributes = []}
      in
      Exp.object_ {pcstr_self = Pat.any (); pcstr_fields = List.map meth labels}
    in
    let mkfun = Exp.fun_ Label.nolabel None in
    let runner = mkfun (pvar "x") (app [%expr Multiparty._run_internal] [obj; evar "x"]) in
    let quoter = Ppx_deriving.create_quoter () in
    let varname = "run_" ^ name in
    [{pstr_desc = Pstr_value (Nonrecursive, [Vb.mk (pvar varname) (Ppx_deriving.sanitize ~quoter runner)]); pstr_loc = Location.none}]
  | _ -> error loc "run_* can be derived only for record or closed object types" 

let has_runner attrs =
  List.exists (fun ({txt = name},_) -> name = "runner")  attrs
       
let mapper_fun _ =
  let open Ast_mapper in
  let expr mapper outer =
  match outer.pexp_desc with
  | Pexp_extension ({ txt = id }, PStr [{ pstr_desc = Pstr_eval (inner, attrs) }]) ->
     begin match expression_mapper id mapper inner attrs with
     | Some exp -> exp
     | None -> default_mapper.expr mapper outer
     end
  | _ -> default_mapper.expr mapper outer
  and stritem mapper outer =
    match outer with
    | {pstr_desc = Pstr_extension (({ txt = "s_syntax_rebind" }, PStr [{ pstr_desc = Pstr_eval ({pexp_desc=Pexp_pack modexpr}, _) }]),_) }->
       rebind_module modexpr;
       [{outer with pstr_desc = Pstr_eval ([%expr ()],[])}] (* replace with () *)
    | {pstr_desc = Pstr_type (_, type_decls)} ->
       let runners =
         List.map (fun type_decl ->
           if has_runner type_decl.ptype_attributes then
             [runner type_decl]
           else []) type_decls
       in [outer] @ List.flatten (List.flatten runners)
    | _ -> [default_mapper.structure_item mapper outer]
  in
  let structure mapper str =
    List.flatten (List.map (stritem mapper) str)
  in
  {default_mapper with expr; structure}
