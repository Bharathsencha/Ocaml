open Httpun
open Httpun_types

let request_handler _addr reqd =
  let { Gluten.reqd; _ } = reqd in
  let headers =
    Headers.of_list
      [ "content-type", "text/plain"
      ; "content-length", "13"
      ; "connection", "keep-alive"
      ]
  in
  let response = Response.create ~headers `OK in
  Reqd.respond_with_string reqd response "Hello, World!"

let error_handler _addr ?request:_ _error start_response =
  let response_body = start_response Headers.empty in
  Body.Writer.write_string response_body "Error" ;
  Body.Writer.close response_body

let run_domain port domain_id =
  Eio_main.run @@ fun env ->
  Eio.Switch.run @@ fun sw ->
  let net = Eio.Stdenv.net env in
  let addr = `Tcp (Eio.Net.Ipaddr.V4.loopback, port) in
  let socket =
    Eio.Net.listen
      ~reuse_addr:true
      ~reuse_port:true
      ~backlog:4096
      ~sw
      net
      addr
  in
  let connection_handler =
    Httpun_eio.Server.create_connection_handler
      ~request_handler
      ~error_handler
      ~sw
  in
  Printf.printf "Domain %d listening on port %d...\n%!" domain_id port;
  while true do
    Eio.Net.accept_fork
      socket
      ~sw
      ~on_error:(fun _exn -> ())
      (fun flow client_addr ->
        connection_handler client_addr flow)
  done

let () =
  let port = 8080 in
  let num_domains = Domain.recommended_domain_count () in
  Printf.printf "Starting HTTP server on http://127.0.0.1:%d using %d domains (cores)...\n%!" port num_domains;
  for id = 1 to num_domains - 1 do
    ignore (Domain.spawn (fun () -> run_domain port id))
  done;
  run_domain port 0
