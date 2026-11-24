#!/bin/bash
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "$DIR"

echo "============================================================"
echo "=== Resource Constraints: 0.5 CPU Core (50%) & 256MB RAM ==="
echo "============================================================"

# Prepare Single-Domain OCaml Server
cat << 'OEOF' > /tmp/ocaml_server_single.ml
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

let () =
  let port = 8080 in
  Eio_main.run @@ fun env ->
  Eio.Switch.run @@ fun sw ->
  let net = Eio.Stdenv.net env in
  let addr = `Tcp (Eio.Net.Ipaddr.V4.loopback, port) in
  let socket =
    Eio.Net.listen
      ~reuse_addr:true
      ~reuse_port:true
      ~backlog:2048
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
  Printf.printf "Single-Domain OCaml Eio Server ready on :%d\n%!" port;
  while true do
    Eio.Net.accept_fork
      socket
      ~sw
      ~on_error:(fun _exn -> ())
      (fun flow client_addr ->
        connection_handler client_addr flow)
  done
OEOF

# Prepare Go Single-Core Server
cat << 'GEOF' > /tmp/go_server_single.go
package main

import (
	"fmt"
	"net/http"
	"runtime"
)

func main() {
	runtime.GOMAXPROCS(1)
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "text/plain")
		w.Write([]byte("Hello, World!"))
	})
	fmt.Println("Single-Core Go net/http Server ready on :8081")
	http.ListenAndServe(":8081", nil)
}
GEOF

echo "=== Compiling Servers ==="
eval $(opam env)
ocamlfind ocamlopt -package eio,eio_main,httpun,httpun-eio,httpun-types -linkpkg -O3 /tmp/ocaml_server_single.ml -o /tmp/ocaml_server_single
go build -o /tmp/go_server_single /tmp/go_server_single.go

cleanup() {
  kill -9 $OCAML_PID $GO_PID 2>/dev/null || true
  rm -f /tmp/ocaml_server_single* /tmp/go_server_single*
}
trap cleanup EXIT

echo ""
echo "=== Testing OCaml 5 Eio (0.5 Core & 256MB RAM) ==="
systemd-run --user --scope -p CPUQuota=50% -p MemoryMax=256M /tmp/ocaml_server_single &
OCAML_PID=$!
sleep 1

# Measure memory consumption of OCaml server
OCAML_MEM=$(ps -p $OCAML_PID -o rss= 2>/dev/null || echo "0")
echo "OCaml Initial RSS Memory: $((OCAML_MEM / 1024)) MB"

echo "Running wrk benchmark against OCaml (4 threads, 100 conns, 10s)..."
wrk -t4 -c100 -d10s --latency http://127.0.0.1:8080/

kill -9 $OCAML_PID 2>/dev/null || true
sleep 1

echo ""
echo "=== Testing Go 1.22 net/http (0.5 Core & 256MB RAM) ==="
systemd-run --user --scope -p CPUQuota=50% -p MemoryMax=256M /tmp/go_server_single &
GO_PID=$!
sleep 1

# Measure memory consumption of Go server
GO_MEM=$(ps -p $GO_PID -o rss= 2>/dev/null || echo "0")
echo "Go Initial RSS Memory: $((GO_MEM / 1024)) MB"

echo "Running wrk benchmark against Go (4 threads, 100 conns, 10s)..."
wrk -t4 -c100 -d10s --latency http://127.0.0.1:8081/

kill -9 $GO_PID 2>/dev/null || true

echo ""
echo "=== Benchmark Complete ==="
