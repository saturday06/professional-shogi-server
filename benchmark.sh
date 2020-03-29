#!/bin/sh

set -eux

cd "$(dirname "$0")"
mkdir -p target
exec ./misc/benchmark-main.sh "$@" | tee target/benchmark-$(LC_ALL=C date +%Y%m%d%H%M%S).txt
