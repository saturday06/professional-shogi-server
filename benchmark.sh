#!/bin/sh

set -eux

cd "$(dirname "$0")"
mkdir -p target
start_time=$(LC_ALL=C date +%Y%m%d%H%M%S)
(./misc/benchmark-main.sh "$@" 2>&1 | tee target/benchmark-${start_time}.txt) || true
cat target/benchmark-${start_time}.txt | grep -E 'run \./driver/|Requests/sec:|Trnsfer/sec:|Socket errors: connect'| tee target/summary-${start_time}.txt
