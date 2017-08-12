module type ROLE = sig
  type 'a kind
  type 'a role
  type pair = Pair : 'a role * 'a -> pair

  val string_of_role : 'a role -> string
  val make_role : 'a kind -> string -> 'a role
  val roleeq : _ role -> _ role -> bool
  val unpack : 'a role -> pair -> 'a
end
                 
    
module Make(LinIO:Linocaml.Base.LIN_IO)(Role:ROLE)
       : Base.ENDPOINT with module LinIO = LinIO and type 'c role = 'c Role.role
= struct
  module LinIO = LinIO
  module IO = LinIO.IO

  module RoleKey = struct
    type 'a key = 'a Role.role
    let equal = Role.roleeq
    type pair = Role.pair = Pair : 'a key * 'a -> pair
    let unpack = Role.unpack
  end

  type 'c conn = {conn    : 'c;
                  send    : 'a. 'c -> 'a -> unit IO.io;
                  receive : 'a. 'c -> 'a IO.io;
                  close   : 'c -> unit IO.io}

  type 'c connector = unit -> 'c conn IO.io
  type 'c acceptor  = unit -> 'c conn IO.io

  type 'c rolekind = 'c conn Role.kind
  type 'c role = 'c Role.role
  let string_of_role = Role.string_of_role
  let make_role = Role.make_role

  module RoleMap = GHashtbl.Make(RoleKey)

  type t = {self: string; role2conn : RoleMap.t}

  let myname {self} = self
                    
  let init : string -> t IO.io = fun role ->
    IO.return {self=role; role2conn=RoleMap.create 42}
    
  let connect : t -> 'c conn role -> 'c connector -> unit IO.io = fun t role conn ->
    let open IO in
    conn () >>= fun raw ->
    (RoleMap.add t.role2conn role raw; return ())
    
  let accept : t -> 'c conn role -> 'g acceptor -> unit IO.io = fun t role acpt ->
    let open IO in
    acpt () >>= fun raw ->
    (RoleMap.add t.role2conn role raw; return ())
    
  let attach : t -> 'c conn role -> 'c conn -> unit = fun t role conn ->
    RoleMap.add t.role2conn role conn

  let detach : t -> 'c conn role -> 'c conn = fun t role ->
    let conn = RoleMap.find t.role2conn role in
    RoleMap.remove t.role2conn role;
    conn

  let get_connection : t -> otherrole:'c conn role -> 'c conn = fun t ~otherrole ->
    RoleMap.find t.role2conn otherrole
                                                          end

