module type BodyImpl = sig
  val schedule_read :
    on_eof:(unit -> unit) -> on_read:(Bigstringaf.t -> off:int -> len:int -> unit) -> unit
end

module type HttpClientImpl = sig
  val request :
    body:Http_intf.input_body ->
    method_:Http_intf.method_ ->
    headers:Http_intf.headers ->
    sw:Eio.Switch.t ->
    string ->
    string ->
    Response.t * (module BodyImpl)

  val shutdown : unit -> unit Eio.Promise.t
end