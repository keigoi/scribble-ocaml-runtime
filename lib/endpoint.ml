
module Make(LinIO:Linocaml.Base.LIN_IO) : Base.ENDPOINT with module LinIO = LinIO
  = struct
  module LinIO = LinIO
  module IO = LinIO.IO

  module type BINARY_CONN = Base.BINARY_CONN with type 'a Binary.io = 'a IO.io
  type conn = (module BINARY_CONN)

  type 'g connector = unit -> conn IO.io
  type 'g acceptor  = unit -> conn IO.io

  type t = {self: Base.role; role2bin : (string, conn) Hashtbl.t}

  let myname {self} = self
         
  let init : Base.role -> t IO.io = fun role ->
    IO.return {self=role; role2bin=Hashtbl.create 42}
    
  let connect : t -> Base.role -> 'g connector -> unit IO.io = fun t role conn ->
    let open IO in
    conn () >>= fun raw ->
    (Hashtbl.add t.role2bin role raw; return ())
      
  let accept : t -> Base.role -> 'g acceptor -> unit IO.io = fun t role acpt ->
    let open IO in
    acpt () >>= fun raw ->
    (Hashtbl.add t.role2bin role raw; return ())
      
  let attach : t -> Base.role -> conn -> unit = fun t role conn ->
    Hashtbl.add t.role2bin role conn

  let detach : t -> Base.role -> conn = fun t role ->
    let conn = Hashtbl.find t.role2bin role in
    Hashtbl.remove t.role2bin role;
    conn

  let get_connection : t -> othername:Base.role -> conn = fun t ~othername ->
    Hashtbl.find t.role2bin othername
end

