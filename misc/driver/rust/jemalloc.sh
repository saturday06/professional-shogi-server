#!/bin/sh

set -eux

exec "$(dirname "$0")/../../../target/benchmark-jemalloc/release/professional-shogi-server" --port $1 --upstream-addr $2
