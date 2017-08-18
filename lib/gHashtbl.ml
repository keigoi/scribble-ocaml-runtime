(* hashtable, in which value type is dependent on key types,  
   from http://alan.petitepomme.net/cwn/2013.07.16.html#2 *)

module type GS =
  sig
    type 'a key
    type t
    val create : int -> t
    val add : t -> 'a key -> 'a -> unit
    val remove : t -> 'a key -> unit
    val find : t -> 'a key -> 'a
    val iter : < f: 'a. 'a key -> 'a -> unit > -> t -> unit
    val mem : t-> 'a key -> bool
  end

module type GHashedType =
  sig
    type _ key
    val equal : _ key -> _ key -> bool
    (* val hash : _ key -> int *)

    type pair = Pair : 'a key * 'a -> pair
    val unpack : 'a key -> pair -> 'a
  end
  
module Make (G : GHashedType) :
GS with type 'a key = 'a G.key =
struct
  include G
  type k = Key : 'a key -> k
  module H = Hashtbl.Make(struct
                           type t = k
                           let hash (Key k) = Hashtbl.hash k
                           let equal (Key l) (Key r) = equal l r
                         end)

  type t = pair H.t

  let create n = H.create n

  let add tbl k v = H.add tbl (Key k) (Pair (k, v))

  let remove tbl k = H.remove tbl (Key k)

  let find tbl key = unpack key (H.find tbl (Key key))

  let iter (f : <f: 'a. 'a key -> 'a -> unit>) tbl =
    H.iter (fun _ (Pair (k, v)) -> f#f k v) tbl

  let mem tbl k = H.mem tbl (Key k)
end
