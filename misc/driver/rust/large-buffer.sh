#!/bin/sh

set -eux

exec "$(dirname "$0")/../../../target/release/professional-shogi-server" --port $1 --upstream-addr $2 --buffer-size $(expr 1024 \* 1024 \* 4)
