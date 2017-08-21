    
module Make(IO:Linocaml.Base.IO)(ConnKind:Base.CONN_KIND)
: Base.ENDPOINT with module ConnKind = ConnKind and type 'a io = 'a IO.io
= struct
  module ConnKind = ConnKind
  type +'a io = 'a IO.io

  type 'c conn = {handle: 'c; close: unit -> unit IO.io}
  type 'c connector = unit -> 'c conn IO.io
  type 'c acceptor  = unit -> 'c conn IO.io

  module MapKey = struct
    type 'a key = Key : 'a ConnKind.t * string -> 'a conn key
    type pair = Pair : 'a key * 'a -> pair

    let equal : type a b. a key -> b key -> bool = fun k1 k2 ->
      match k1, k2 with (Key(k1,str1)), (Key(k2,str2)) -> ConnKind.eq k1 k2 && str1=str2

    let unpack : type a. a key -> pair -> a = fun k pair ->
      match k, pair with
      | Key(k1, _), Pair(Key(k2,_),{handle;close}) ->
         let h = ConnKind.unpack k1 (ConnKind.Pair(k2,handle)) in
         {handle=h;close}
  end
  module Map = GHashtbl.Make(MapKey)

  type 'a key = 'a ConnKind.t * string

  let create_key kind str = kind, str
  let string_of_key (_,str) = str
  let kind_of_key (k,_) = k
                             
  type t = {myname: string; role2conn : Map.t}

  let myname {myname} = myname
                      
  let create : myname:string -> t = fun ~myname ->
    {myname; role2conn=Map.create 42}

  let close : t -> unit IO.io = fun {role2conn} ->
    let r = ref [] in
    Map.iter (object method f : type a. a MapKey.key -> a -> unit = fun k v -> match k,v with (MapKey.Key(_,_)),{close} -> r := close :: !r end) role2conn;
    let open IO in
    let rec close = function
      | [] -> return ()
      | c::cs -> c () >>= fun _ -> close cs
    in
    close !r
    
    
  let connect : t -> 'c key -> 'c connector -> unit IO.io = fun t (k,s) conn ->
    let open IO in
    conn () >>= fun raw ->
    (Map.add t.role2conn (MapKey.Key(k,s)) raw; return ())
    
  let accept : t -> 'c key -> 'c acceptor -> unit IO.io = fun t (k,s) acpt ->
    let open IO in
    acpt () >>= fun raw ->
    (Map.add t.role2conn (MapKey.Key(k,s)) raw; return ())
    
  let attach : t -> 'c key -> 'c conn -> unit = fun t (k,s) conn ->
    Map.add t.role2conn (MapKey.Key(k,s)) conn

  let detach : t -> 'c key -> 'c conn = fun t (k,s) ->
    let conn = Map.find t.role2conn (MapKey.Key(k,s)) in
    Map.remove t.role2conn (MapKey.Key(k,s));
    conn

  let get_connection : t -> 'c key -> 'c conn = fun t (k,s) ->
    Map.find t.role2conn (MapKey.Key(k,s))

end

