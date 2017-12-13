    
module Make(IO:Linocaml.Base.IO)
: Base.ENDPOINT with type 'a io = 'a IO.io
= struct
  type +'a io = 'a IO.io

  type 'c conn = {handle: 'c; close: unit -> unit IO.io}
  type 'c conn_kind = ..
  type 'c connector = unit -> 'c conn IO.io
  type 'c acceptor  = unit -> 'c conn IO.io
                    
  type pair = Pair : 'c conn_kind * 'c -> pair
  let unpack : 'c conn_kind -> pair -> 'c =
    fun _ (Pair(_,p)) -> Obj.magic p

  let conn_kind_eq : 'c1 'c2. 'c1 conn_kind -> 'c2 conn_kind -> bool =
    fun k1 k2 ->
    k1 = Obj.magic k2

  module MapKey = struct
    type 'a key = Key : 'a conn_kind * string -> 'a conn key
    type pair = Pair : 'a key * 'a -> pair

    let equal : type a b. a key -> b key -> bool = fun k1 k2 ->
      match k1, k2 with (Key(k1,str1)), (Key(k2,str2)) -> conn_kind_eq k1 k2 && str1=str2

    let unpack : type a. a key -> pair -> a = fun k pair ->
      match k, pair with
      | Key(k1, _), Pair(Key(k2,_),{handle;close}) ->
         let h = unpack k1 (Pair(k2,handle)) in
         {handle=h;close}
  end
  module Map = GHashtbl.Make(MapKey)

  type 'a key = 'a conn_kind * string

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

