#!/bin/sh

set -eux

cd "$(dirname "$0")"
mkdir -p target
exec nice -n -10 ./misc/benchmark-main.sh "$@" 2>&1 | tee target/benchmark-$(LC_ALL=C date +%Y%m%d%H%M%S).txt
