#!/bin/sh

set -eux

exec "$(dirname "$0")/go" -port $1 -upstreamAddr $2 -useHttputil true
