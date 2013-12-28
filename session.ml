type ('a,'b) either = 
  | Left : 'a -> ('a,'b) either 
  | Right : 'b -> ('a,'b) either

module Session : sig
  type ('an,'bn,'a,'b) idx
  type (+'hd, +'tl) cons
  type empty
  type all_empty = (empty, 'a) cons as 'a

  val _0 : ('a0, 'b0, ('a0,'a) cons, ('b0,'a) cons) idx
  val _1 : ('a1, 'b1, ('a0,('a1,'a) cons) cons, ('a0,('b1,'a) cons) cons) idx
  val _2 : ('a2, 'b2, ('a0,('a1,('a2,'a) cons) cons) cons, ('a0,('a1,('b2,'a) cons) cons) cons) idx
  val _3 : ('a3, 'b3, ('a0,('a1,('a2,('a3,'a) cons) cons) cons) cons, ('a0,('a1,('a2,('b3,'a) cons) cons) cons) cons) idx
  val succ : ('an, 'bn, 'a, 'b) idx -> ('an, 'bn, ('a0,'a) cons, ('a0,'b) cons) idx

  type ('p,'q,'a) monad
  val ret : 'a -> ('p, 'p, 'a) monad
  val (>>=) : ('p,'q,'a) monad -> ('a -> ('q,'r,'b) monad) -> ('p,'r,'b) monad
  val (>>) : ('p,'q,'a) monad -> ('q,'r,'b) monad -> ('p,'r,'b) monad
  val fmap : ('a -> 'b) -> 'a -> ('p,'p,'b) monad
  val slide : ('p,'q,'a) monad -> (('p0,'p)cons,('p0,'q)cons,'a) monad

  val run : (all_empty,all_empty,'a) monad -> 'a

  type ('s, 'v, 'k) shot
  type finish
         
  type pos and neg

  type ('s, 't, 'k) channel
                    
  val send : (('s,'t,('s,'a,'k)shot)channel , ('s,'t,'k) channel, 'p, 'q) idx -> 'a -> ('p,'q,unit) monad
  val recv : (('s,'t,('t,'a,'k)shot)channel, ('s,'t,'k) channel, 'p, 'q) idx -> ('p,'q,'a) monad
  val close : (('s,'t,finish)channel, empty, 'p, 'q) idx -> ('p, 'q, unit) monad

(*
  val send_chan : 
    (('s,'k) send_chan, 'k, 'q, 'r) t -> 
    ('s, empty, 'p, 'q) t ->
    ('p,'r,unit) monad
  val recv_chan :
    (('s,'k) recv_chan, 'k, 'p, 'q) t ->
    (empty, 's, 'q, 'r) t ->
    ('p,'r,unit) monad
  val send_left :
    (('k1,'k2) select, 'k1, 'p, 'q) t ->
    ('p,'q,unit) monad
  val send_right :
    (('k1,'k2) select, 'k2, 'p, 'q) t ->
    ('p,'q,unit) monad
  val branch : 
    (('k1,'k2) branch,empty, 'p,'q) t -> 
    (empty,'k1, 'q,'q1) t * ('q1,'r,'a) monad ->
    (empty,'k2, 'q,'q2) t * ('q2,'r,'a) monad ->
    ('p,'r,'a) monad
 *)
  val fork : 
    (empty, (pos,neg,'k)channel, 'p, 'q) idx -> 
    (((neg,pos,'k)channel, all_empty) cons, all_empty, unit) monad -> 
    ('p,'q,unit) monad

end 
= struct
  type ('a,'b,'p,'q) idx = ('p -> 'a) * ('p -> 'b -> 'q)
  type ('hd, 'tl) cons = 'hd * 'tl
  type empty = Empty
  type all_empty = empty * all_empty

  let _0 = (fun (a0,_) -> a0), (fun (_,a) b0 -> (b0,a))
  let _1 = (fun (_,(a1,_)) -> a1), (fun (a0,(_,a)) b1 -> (a0,(b1,a)))
  let _2 = (fun (_,(_,(a2,_))) -> a2), (fun (a0,(a1,(_,a))) b2 -> (a0,(a1,(b2,a))))
  let _3 = (fun (_,(_,(_,(a3,_)))) -> a3), (fun (a0,(a1,(a2,(_,a)))) b3 -> (a0,(a1,(a2,(b3,a)))))
  let succ (get,set) = (fun (_,a) -> get a), (fun (a0,a) bn -> (a0,set a bn))

  type ('p,'q,'a) monad = 'p -> 'q * 'a
  let ret a p = p, a
  let (>>=) m f p = let (q,a) = m p in f a q
  let (>>) m n p =  let (q,_) = m p in n q
  let fmap f a p = p, f a
  let slide m (p0,p) = let (q,a) = m p in (p0,q),a

  let rec all_empty = Empty, all_empty
  let run m = snd (m all_empty)

  type pos = Pos and neg = Neg

  type ('s,'v,'k) shot = Shot of 's * 'v * 'k Channel.t
  type finish = unit

  type ('s,'t,'k) channel = Chan of 's * 't * 'k Channel.t

(*
  type ('a,'b,'t) tag = 
    | Tag_left : ('a,'b,'a) tag
    | Tag_right : ('a,'b,'b) tag
  
  type ('a, 'k) send = 'a -> 'k
  type ('a, 'k) recv = unit -> 'a * 'k
  type ('s, 'k) send_chan = 's -> 'k
  type ('s, 'k) recv_chan = unit -> 's * 'k
  type ('k1, 'k2) select = {select:'k. ('k1,'k2,'k) tag -> 'k}
  type ('k1, 'k2) branch = unit -> ('k1,'k2) either
 *)

  let send (get,set) v p =
    let Chan(s,t,c) = get p in
    let c' = Channel.create () in
    Channel.send c (Shot(s,v,c'));
    set p (Chan(s,t,c')), ()
                                     
  let recv (get,set) p =
    let Chan(s,t,c) = get p in
    let Shot(t, v, c') = Channel.receive c in
    set p (Chan(s,t,c')), v

  let close (get,set) p =
    set p Empty, ()
(*               
  let send_chan (get0,set0) (get1,set1) p = 
    let s, q = get1 p, set1 p Empty in
    let r = set0 q (get0 q s) in
    r, ()
  let recv_chan (get0,set0) (get1,set1) p =
    let s, k = get0 p () in
    let q = set0 p k in
    let r = set1 q s in
    r, ()
  let send_left (get0,set0) p =
    set0 p ((get0 p).select Tag_left), ()
  let send_right (get0,set0) p =
    set0 p ((get0 p).select Tag_right), ()
  let branch (get0,set0) ((get1,set1),m1) ((get2,set2),m2) p =
    let k,q = get0 p (), set0 p Empty in
    match k with
      | Left k1 -> m1 (set1 q k1)
      | Right k2 -> m2 (set2 q k2)
  
 *)
  let fork (get,set) m p = 
    let chan = Channel.create () in
    ignore (Thread.create (fun _ -> ignore (m (Chan(Neg,Pos,chan),all_empty))) ());
    set p (Chan(Pos,Neg,chan)), ()

end;;

include Session;;

let p () = 
  send _0 1234 >>
  recv _0 >>= 
  fmap print_endline >>
  close _0 >>
  ret ()
      
      (*
val p :
    unit ->
      ((('a, 'b, ('a, int, ('b, string, finish) shot) shot) chan, 'c) cons,
          (empty, 'c) cons, unit)
          monad = <fun>
       *)
(*
val p :
  unit ->
  (((int, (string, 'a) recv) send, 'b) cons, ('a, 'b) cons, unit) monad
*)

let q () =
  recv _0 >>= fun i ->
  send _0 (string_of_int (i*2)) >>
  close _0 >>
  ret ()
(*
val q :
    unit ->
      ((('a, 'b, ('b, int, ('a, string, finish) shot) shot) chan, 'c) cons,
          (empty, 'c) cons, unit)
          monad
*)

let r () = 
  fork _0 (q ()) >>
  p ()
(*
val r :
    unit ->
      ((empty, (empty, 'a) cons) cons, (empty, (empty, 'a) cons) cons, unit)
          monad
*)

let _ = run (r())

(*
let p2 () = 
  send _0 7777 >>
  recv_chan _0 _1 >>
  recv _1 >>= fmap print_endline

let q2 () =
  recv _0 >>= fun v ->
  new_chan _1 _2 (a2b finish) >>
  send_chan _0 _2 >>
  send _1 (string_of_int (v - 1111))

let r2 () =
  new_chan _0 _1 (a2b (b2a_chan finish)) >>
  fork _1 (q2 ()) >>
  p2 ()

let _ = run (r2())

let rec p3 n =
    if n>10 then 
      send_right _0 >> ret () 
    else
      send_left _0 >>
        send _0 n >>
        recv _0 >>= fmap print_endline >>
        p3 (n+1)

let rec q3 () = 
  branch _0
    (_0,recv _0 >>= fun x ->
        send _0 (string_of_int x) >>
        q3 ())
    (_0,ret ())

let r3 () =
  new_chan _0 _1 (let rec r = lazy (a2b_branch (a2b (b2a (!! r))) finish) in !!r) >>= fun _ ->
  fork _1 (q3 ()) >>
  p3 1

let _ = run (r3 ())
 *)

(* let v () = branch {alt=Alt(_0,fun _ -> failwith "")} *)
