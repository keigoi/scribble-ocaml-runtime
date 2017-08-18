module Chan = Channel.Make
                (Linocaml_lwt.IO)
                (struct
                  type +'a io = 'a Lwt.t
                  include Lwt_mutex
                end)
                (struct
                  type +'a io = 'a Lwt.t
                  type m = Lwt_mutex.t
                  type t = unit Lwt_condition.t
                  let create = Lwt_condition.create
                  let signal c = Lwt_condition.signal c ()
                  let wait c m = Lwt_condition.wait ~mutex:m c
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
          (Linocaml_lwt)
          (Chan)
          (RawChan)
          (Endpoint.Make(Linocaml_lwt.IO)(RawChan)(ConnKind))
