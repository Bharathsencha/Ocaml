#!/bin/bash
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "$DIR"

# Increase file descriptor limit
ulimit -n 65535 || true

echo "=== Building OCaml HTTP Server ==="
eval $(opam env)
dune build

echo "=== Starting OCaml Eio Multicore HTTP Server ==="
./_build/default/server.exe &
SERVER_PID=$!

cleanup() {
  echo "=== Stopping Server (PID $SERVER_PID) ==="
  kill -9 $SERVER_PID 2>/dev/null || true
}
trap cleanup EXIT

# Wait for server to boot
sleep 1

echo "=== Health check ==="
curl -i http://127.0.0.1:8080/

echo ""
echo "============================================================"
echo "=== Running WRK Stress Test (10s, 8 threads, 200 conns) ==="
echo "============================================================"
wrk -t8 -c200 -d10s --latency http://127.0.0.1:8080/

echo ""
echo "============================================================"
echo "=== Running Heavy WRK Stress Test (10s, 12 threads, 500 conns) ==="
echo "============================================================"
wrk -t12 -c500 -d10s --latency http://127.0.0.1:8080/

echo "=== Stress Test Finished Successfully ==="
