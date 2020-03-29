#!/bin/sh

set -eux

run_task() (
  group=$1
  shift

  if [ $(uname -s) = "Linux" ]; then
    cpu_list=$(awk 'BEGIN{for (i = 0; i < ARGV[1] / 4; i++) { if (i > 0) printf(","); printf("%d", i + ARGV[1] * ARGV[2] / 4);}}' $(nproc) $group)
    exec taskset --cpu-list $cpu_list $@
  else
    exec $@
  fi
)

run() (
  executable=$1
  path=$2
  connection=$3
  thread=$4
  port=13001
  upstream_addr=127.0.0.1:18888

  run_task 1 $executable $port $upstream_addr &
  executable_pid=$!
  sleep 1

  run_task 2 nginx -p "$PWD" -c "$PWD/nginx.conf" &
  nginx_pid=$!
  sleep 3

  run_task 2 wrk -d 60 -t $thread -c $connection -H 'Host: example' http://127.0.0.1:$port/$path > /dev/null
  sleep 1
  run_task 2 wrk -d 120 -t $thread -c $connection -H 'Host: example' http://127.0.0.1:$port/$path

  kill $executable_pid
  wait $executable_pid || true
  kill $nginx_pid
  wait $nginx_pid || true

  sleep 10
)

if [ $(uname -s) = "Darwin" ]; then
  nproc() (
    sysctl -n hw.logicalcpu
  )
fi

cd "$(dirname "$0")"

ulimit_n=$(ulimit -n)
if [ $ulimit_n -lt 32768 ]; then
  cat <<WARNING >&2
##############################################
   ulimit -n is less than 32768 but $ulimit_n
##############################################
WARNING
  # exit 1
fi

./generate-data.sh
cargo build --release
(cd driver/go && go build)

for thread in $(expr $(nproc) / 2) $(nproc); do
  for path in 8k 16k 32k 64k 128k 256k 512k 768k 1m 2m 3m 4m 6m 8m 16m 32m 64m; do
    for connection in 100; do
      for executable in $(find ./driver -name "*.sh" | sort); do
        run $executable $path $connection $thread
      done
    done
  done
done
