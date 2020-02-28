#!/bin/sh

set -eux

run() (
  executable=$1
  path=$2
  connection=$3
  thread=$4
  port=13001
  upstream_addr=127.0.0.1:18888

  $executable $port $upstream_addr &
  executable_pid=$!
  sleep 3

  wrk -d 60 -t $thread -c $connection -H 'Host: example' http://127.0.0.1:$port/$path > /dev/null
  sleep 1
  wrk -d 120 -t $thread -c $connection -H 'Host: example' http://127.0.0.1:$port/$path

  kill $executable_pid
  wait $executable_pid || true

  sleep 10
)

cd $(dirname "$0")/..

cargo build --release
(cd benchmark/go && go build)

for path in 8k 16k 32k 64k 128k 256k 512k 768k 1m 2m 3m 4m 6m 8m 16m 32m 64m; do
  for thread in 8; do
    for connection in 100; do
      for executable in \
        ./benchmark/rust/default.sh \
        ./benchmark/rust/no-macro.sh \
        ./benchmark/go/default.sh \
        ./benchmark/go/httputil.sh \
      ; do
        run $executable $path $connection $thread
      done
    done
  done
done
