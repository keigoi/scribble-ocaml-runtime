module Chan = Channel.Make
                (Linocaml.Direct.IO)
                (struct
                  type +'a io = 'a
                  include Mutex
                end)
                (struct
                  type +'a io = 'a
                  type m = Mutex.t
                  include Condition
                end)
module RawChan = Unsafe.Make_raw_dchan(Dchannel.Make(Chan))

module ConnKind = struct
  type _ t = Shmem : RawChan.t t
  type pair = Pair : 'a t * 'a -> pair

  let eq : type a b. a t -> b t -> bool =
    fun r1 r2 ->
    match r1, r2 with
    | Shmem, Shmem -> true

  let unpack : type a. a t -> pair -> a =
    fun r p -> match r, p with
    | Shmem, (Pair(Shmem,v)) -> v

  type shmem_chan = RawChan.t
  let shmem_chan_kind = Shmem
end
               
include Session.Make
          (Linocaml.Direct)
          (Chan)
          (RawChan)
          (ConnKind)
