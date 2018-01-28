(* Generated from scribble-ocaml https://github.com/keigoi/scribble-ocaml
 * This code should be compiled with scribble-ocaml-runtime
 * https://github.com/keigoi/scribble-ocaml-runtime *)

module type TYPES = sig
  type page
end

module Make (Session:Scribble.Base.SESSION) (Types:TYPES) = struct
  type id = string
  type pass = string
  type state = string
  type accessToken = string
  type code = string
  type page = Types.page

open Session

type ('c_C, 'c_P) oAuth_U = ('c_C, 'c_P) oAuth_U_1
and ('c_C, 'c_P) oAuth_U_1 =
  [`connect of [`C of 'c_C * [`oauth of unit data *
    [`recv of [`C of 'c_C * [`_302_oauth_start of state data *
      [`disconnect of [`C of 'c_C *
        [`connect of [`P of 'c_P * [`authorize_request of state data *
          [`recv of [`P of 'c_P * [`_200 of page data *
            [`disconnect of [`P of 'c_P *
              [`connect of [`P of 'c_P * [`submit of (id * pass) data *
                [`recv of [`P of 'c_P *
                  [`_302_success of code data *
                    [`disconnect of [`P of 'c_P *
                      [`connect of [`C of 'c_C * [`callback_success of code data *
                        [`recv of [`C of 'c_C * [`_200 of page data *
                          [`disconnect of [`C of 'c_C *
                            [`close] sess]] sess]]] sess]]] sess]] sess
                  |`_302_fail of unit data *
                    [`disconnect of [`P of 'c_P *
                      [`connect of [`C of 'c_C * [`callback_fail of unit data *
                        [`recv of [`C of 'c_C * [`_200 of page data *
                          [`close] sess]]] sess]]] sess]] sess]]] sess]]] sess]] sess]]] sess]]] sess]] sess]]] sess]]]
type ('c_U, 'c_P) oAuth_C = ('c_U, 'c_P) oAuth_C_1
and ('c_U, 'c_P) oAuth_C_1 =
  [`accept of [`U of 'c_U * [`oauth of unit data *
    [`send of [`U of 'c_U * [`_302_oauth_start of state data *
      [`disconnect of [`U of 'c_U *
        [`accept of [`U of 'c_U *
          [`callback_success of code data *
            [`connect of [`P of 'c_P * [`access_token of unit data *
              [`recv of [`P of 'c_P * [`_200 of accessToken data *
                [`disconnect of [`P of 'c_P *
                  [`send of [`U of 'c_U * [`_200 of page data *
                    [`disconnect of [`U of 'c_U *
                      [`close] sess]] sess]]] sess]] sess]]] sess]]] sess
          |`callback_fail of unit data *
            [`send of [`U of 'c_U * [`_200 of page data *
              [`close] sess]]] sess]]] sess]] sess]]] sess]]]
type ('c_U, 'c_C) oAuth_P = ('c_U, 'c_C) oAuth_P_1
and ('c_U, 'c_C) oAuth_P_1 =
  [`accept of [`U of 'c_U * [`authorize_request of state data *
    [`send of [`U of 'c_U * [`_200 of page data *
      [`disconnect of [`U of 'c_U *
        [`accept of [`U of 'c_U * [`submit of (id * pass) data *
          [`send of [`U of 'c_U *
            [`_302_success of code data *
              [`disconnect of [`U of 'c_U *
                [`accept of [`C of 'c_C * [`access_token of unit data *
                  [`send of [`C of 'c_C * [`_200 of accessToken data *
                    [`disconnect of [`C of 'c_C *
                      [`close] sess]] sess]]] sess]]] sess]] sess
            |`_302_fail of unit data *
              [`disconnect of [`U of 'c_U *
                [`close] sess]] sess]]] sess]]] sess]] sess]]] sess]]]

module U = struct
  let initiate_U : unit -> ('c, 'c, ('c_C, 'c_P) oAuth_U sess) monad =
    fun () -> Internal.__initiate ~myname:"role_U"

  module C = struct
    module Make(X:sig
        type conn
        val conn : conn Endpoint.conn_kind
        val write_oauth : conn -> [>`oauth of unit data * 'p sess] -> unit io
        val write_callback_success : conn -> [>`callback_success of code data * 'p sess] -> unit io
        val write_callback_fail : conn -> [>`callback_fail of unit data * 'p sess] -> unit io
        val read_302_oauth_start : conn -> [`_302_oauth_start of state data * 'p0] io
        val read_200 : conn -> [`_200 of page data * 'p0] io
      end) = struct
      let role : ([>`C of X.conn * 'lab], X.conn, 'lab) role =
        {_pack_role=(fun labels -> `C(labels)) ; _repr="role_C"; _kind=X.conn}

      let oauth : 'p. ([>`oauth of unit data * 'p sess], X.conn, unit data * 'p sess) label =
        {_pack_label=(fun payload -> `oauth(payload)); _send=X.write_oauth}
      let callback_success : 'p. ([>`callback_success of code data * 'p sess], X.conn, code data * 'p sess) label =
        {_pack_label=(fun payload -> `callback_success(payload)); _send=X.write_callback_success}
      let callback_fail : 'p. ([>`callback_fail of unit data * 'p sess], X.conn, unit data * 'p sess) label =
        {_pack_label=(fun payload -> `callback_fail(payload)); _send=X.write_callback_fail}
      let receive_302_oauth_start  : type p0. ([`_302_oauth_start of state data * p0], X.conn) labels =
        {_receive=X.read_302_oauth_start}
      let receive_200  : type p0. ([`_200 of page data * p0], X.conn) labels =
        {_receive=X.read_200}
    end

    module Shmem = struct
      include Make(struct
          type conn = Raw.t
          let conn = Shmem
          let write_oauth = Raw.send
          let write_callback_success = Raw.send
          let write_callback_fail = Raw.send
          let read_302_oauth_start = Raw.receive
          let read_200 = Raw.receive
        end)
        let connector, acceptor = shmem ()
    end
  end
  module P = struct
    module Make(X:sig
        type conn
        val conn : conn Endpoint.conn_kind
        val write_authorize_request : conn -> [>`authorize_request of state data * 'p sess] -> unit io
        val write_submit : conn -> [>`submit of (id * pass) data * 'p sess] -> unit io
        val read_200 : conn -> [`_200 of page data * 'p0] io
        val read_302_success_or_302_fail : conn -> [`_302_success of code data * 'p0|`_302_fail of unit data * 'p1] io
      end) = struct
      let role : ([>`P of X.conn * 'lab], X.conn, 'lab) role =
        {_pack_role=(fun labels -> `P(labels)) ; _repr="role_P"; _kind=X.conn}

      let authorize_request : 'p. ([>`authorize_request of state data * 'p sess], X.conn, state data * 'p sess) label =
        {_pack_label=(fun payload -> `authorize_request(payload)); _send=X.write_authorize_request}
      let submit : 'p. ([>`submit of (id * pass) data * 'p sess], X.conn, (id * pass) data * 'p sess) label =
        {_pack_label=(fun payload -> `submit(payload)); _send=X.write_submit}
      let receive_200  : type p0. ([`_200 of page data * p0], X.conn) labels =
        {_receive=X.read_200}
      let receive_302_success_or_302_fail  : type p0 p1. ([`_302_success of code data * p0|`_302_fail of unit data * p1], X.conn) labels =
        {_receive=X.read_302_success_or_302_fail}
    end

    module Shmem = struct
      include Make(struct
          type conn = Raw.t
          let conn = Shmem
          let write_authorize_request = Raw.send
          let write_submit = Raw.send
          let read_200 = Raw.receive
          let read_302_success_or_302_fail = Raw.receive
        end)
        let connector, acceptor = shmem ()
    end
  end

end

module C = struct
  let initiate_C : unit -> ('c, 'c, ('c_U, 'c_P) oAuth_C sess) monad =
    fun () -> Internal.__initiate ~myname:"role_C"

  module U = struct
    module Make(X:sig
        type conn
        val conn : conn Endpoint.conn_kind
        val write_302_oauth_start : conn -> [>`_302_oauth_start of state data * 'p sess] -> unit io
        val write_200 : conn -> [>`_200 of page data * 'p sess] -> unit io
        val read_oauth : conn -> [`oauth of unit data * 'p0] io
        val read_callback_success_or_callback_fail : conn -> [`callback_success of code data * 'p0|`callback_fail of unit data * 'p1] io
      end) = struct
      let role : ([>`U of X.conn * 'lab], X.conn, 'lab) role =
        {_pack_role=(fun labels -> `U(labels)) ; _repr="role_U"; _kind=X.conn}

      let _302_oauth_start : 'p. ([>`_302_oauth_start of state data * 'p sess], X.conn, state data * 'p sess) label =
        {_pack_label=(fun payload -> `_302_oauth_start(payload)); _send=X.write_302_oauth_start}
      let _200 : 'p. ([>`_200 of page data * 'p sess], X.conn, page data * 'p sess) label =
        {_pack_label=(fun payload -> `_200(payload)); _send=X.write_200}
      let receive_oauth  : type p0. ([`oauth of unit data * p0], X.conn) labels =
        {_receive=X.read_oauth}
      let receive_callback_success_or_callback_fail  : type p0 p1. ([`callback_success of code data * p0|`callback_fail of unit data * p1], X.conn) labels =
        {_receive=X.read_callback_success_or_callback_fail}
    end

    module Shmem = struct
      include Make(struct
          type conn = Raw.t
          let conn = Shmem
          let write_302_oauth_start = Raw.send
          let write_200 = Raw.send
          let read_oauth = Raw.receive
          let read_callback_success_or_callback_fail = Raw.receive
        end)
        let connector, acceptor = shmem ()
    end
  end
  module P = struct
    module Make(X:sig
        type conn
        val conn : conn Endpoint.conn_kind
        val write_access_token : conn -> [>`access_token of unit data * 'p sess] -> unit io
        val read_200 : conn -> [`_200 of accessToken data * 'p0] io
      end) = struct
      let role : ([>`P of X.conn * 'lab], X.conn, 'lab) role =
        {_pack_role=(fun labels -> `P(labels)) ; _repr="role_P"; _kind=X.conn}

      let access_token : 'p. ([>`access_token of unit data * 'p sess], X.conn, unit data * 'p sess) label =
        {_pack_label=(fun payload -> `access_token(payload)); _send=X.write_access_token}
      let receive_200  : type p0. ([`_200 of accessToken data * p0], X.conn) labels =
        {_receive=X.read_200}
    end

    module Shmem = struct
      include Make(struct
          type conn = Raw.t
          let conn = Shmem
          let write_access_token = Raw.send
          let read_200 = Raw.receive
        end)
        let connector, acceptor = shmem ()
    end
  end

end

module P = struct
  let initiate_P : unit -> ('c, 'c, ('c_U, 'c_C) oAuth_P sess) monad =
    fun () -> Internal.__initiate ~myname:"role_P"

  module U = struct
    module Make(X:sig
        type conn
        val conn : conn Endpoint.conn_kind
        val write_200 : conn -> [>`_200 of page data * 'p sess] -> unit io
        val write_302_success : conn -> [>`_302_success of code data * 'p sess] -> unit io
        val write_302_fail : conn -> [>`_302_fail of unit data * 'p sess] -> unit io
        val read_authorize_request : conn -> [`authorize_request of state data * 'p0] io
        val read_submit : conn -> [`submit of (id * pass) data * 'p0] io
      end) = struct
      let role : ([>`U of X.conn * 'lab], X.conn, 'lab) role =
        {_pack_role=(fun labels -> `U(labels)) ; _repr="role_U"; _kind=X.conn}

      let _200 : 'p. ([>`_200 of page data * 'p sess], X.conn, page data * 'p sess) label =
        {_pack_label=(fun payload -> `_200(payload)); _send=X.write_200}
      let _302_success : 'p. ([>`_302_success of code data * 'p sess], X.conn, code data * 'p sess) label =
        {_pack_label=(fun payload -> `_302_success(payload)); _send=X.write_302_success}
      let _302_fail : 'p. ([>`_302_fail of unit data * 'p sess], X.conn, unit data * 'p sess) label =
        {_pack_label=(fun payload -> `_302_fail(payload)); _send=X.write_302_fail}
      let receive_authorize_request  : type p0. ([`authorize_request of state data * p0], X.conn) labels =
        {_receive=X.read_authorize_request}
      let receive_submit  : type p0. ([`submit of (id * pass) data * p0], X.conn) labels =
        {_receive=X.read_submit}
    end

    module Shmem = struct
      include Make(struct
          type conn = Raw.t
          let conn = Shmem
          let write_200 = Raw.send
          let write_302_success = Raw.send
          let write_302_fail = Raw.send
          let read_authorize_request = Raw.receive
          let read_submit = Raw.receive
        end)
        let connector, acceptor = shmem ()
    end
  end
  module C = struct
    module Make(X:sig
        type conn
        val conn : conn Endpoint.conn_kind
        val write_200 : conn -> [>`_200 of accessToken data * 'p sess] -> unit io
        val read_access_token : conn -> [`access_token of unit data * 'p0] io
      end) = struct
      let role : ([>`C of X.conn * 'lab], X.conn, 'lab) role =
        {_pack_role=(fun labels -> `C(labels)) ; _repr="role_C"; _kind=X.conn}

      let _200 : 'p. ([>`_200 of accessToken data * 'p sess], X.conn, accessToken data * 'p sess) label =
        {_pack_label=(fun payload -> `_200(payload)); _send=X.write_200}
      let receive_access_token  : type p0. ([`access_token of unit data * p0], X.conn) labels =
        {_receive=X.read_access_token}
    end

    module Shmem = struct
      include Make(struct
          type conn = Raw.t
          let conn = Shmem
          let write_200 = Raw.send
          let read_access_token = Raw.receive
        end)
        let connector, acceptor = shmem ()
    end
  end

end

end