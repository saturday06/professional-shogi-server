#!/bin/sh

set -eux

cd "$(dirname "$0")"
./misc/benchmark-main.sh &
disown %1
