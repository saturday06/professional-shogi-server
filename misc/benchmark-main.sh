#!/bin/sh

set -eux

run_task() (
  group=$1
  shift

  if [ $(uname -s) = "Linux" ]; then
    cpu_list=$(awk 'BEGIN{for (i = 0; i < ARGV[1] / ARGV[3]; i++) { if (i > 0) printf(","); printf("%d", i + ARGV[1] * ARGV[2] / ARGV[3]);}}' $(nproc) $group 4)
    exec taskset --cpu-list $cpu_list "$@"
  else
    exec "$@"
  fi
)

run() (
  executable=$1
  path=$2
  connection=$3
  thread=$4
  port=13001
  upstream_addr=127.0.0.1:18888

  run_task 0 $executable $port $upstream_addr &
  executable_pid=$!
  sleep 3

  run_task 1 wrk -d 120 -t $thread -c $connection --timeout 10s -H 'Host: example' http://127.0.0.1:$port/$path > /dev/null
  sleep 1
  run_task 1 wrk -d 300 -t $thread -c $connection --timeout 10s -H 'Host: example' http://127.0.0.1:$port/$path

  pkill -TERM -P $executable_pid
  wait $executable_pid || true

  sleep 20
)

if [ $(uname -s) = "Darwin" ]; then
  nproc() (
    sysctl -n hw.logicalcpu
  )
fi

cd "$(dirname "$0")"

recommended_ulimit_n=32768
if [ $(ulimit -n) -lt $recommended_ulimit_n ]; then
  ulimit -n $recommended_ulimit_n
fi
if [ $(ulimit -n) -lt $recommended_ulimit_n ]; then
  cat <<WARNING >&2
##############################################
   ulimit -n is less than 32768 but $(ulimit -n)
##############################################
WARNING
  # exit 1
fi

./generate-data.sh
cargo build --release --target-dir ../target/benchmark-default
cargo build --release --target-dir ../target/benchmark-jemalloc --features global-allocator-jemalloc
(cd driver/go && go build)

mkdir -p "$PWD/upstream/www/html"
nginx -p "$PWD/upstream" -c "$PWD/nginx.conf" -s quit || true
sleep 3
nginx -p "$PWD/upstream" -c "$PWD/nginx.conf" -t
run_task 2 nginx -p "$PWD/upstream" -c "$PWD/nginx.conf" -g 'daemon off;' &
sleep 3

for iteration in 1 2; do
  for thread in $(expr $(nproc) / 2); do
    for path in 8k 16k 32k 64k 128k 256k 512k 768k 1m 2m 3m 4m 6m 8m 16m 32m 64m; do
      for connection in $(expr $(nproc) \* 4); do
        for executable in $(find ./driver -name "*.sh" | sort); do
          run $executable $path $connection $thread
        done
      done
    done
  done
done
