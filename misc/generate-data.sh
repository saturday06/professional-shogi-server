#!/bin/sh

set -eux

cd "$(dirname "$0")"
mkdir -p upstream/www/html
cd upstream/www/html

if [ $(uname -s) = "Linux" ]; then
  iflag='iflag=fullblock'
else
  iflag=
fi

test -f 4k || dd if=/dev/urandom $iflag of=4k bs=4 count=1000
test -f 8k || dd if=/dev/urandom $iflag of=8k bs=8 count=1000
test -f 16k || dd if=/dev/urandom $iflag of=16k bs=16 count=1000
test -f 32k || dd if=/dev/urandom $iflag of=32k bs=32 count=1000
test -f 64k || dd if=/dev/urandom $iflag of=64k bs=64 count=1000
test -f 128k || dd if=/dev/urandom $iflag of=128k bs=128 count=1000
test -f 256k || dd if=/dev/urandom $iflag of=256k bs=256 count=1000
test -f 512k || dd if=/dev/urandom $iflag of=512k bs=512 count=1000
test -f 768k || dd if=/dev/urandom $iflag of=768k bs=768 count=1000
test -f 1m || dd if=/dev/urandom $iflag of=1m bs=1 count=1000000
test -f 2m || dd if=/dev/urandom $iflag of=2m bs=2 count=1000000
test -f 3m || dd if=/dev/urandom $iflag of=3m bs=3 count=1000000
test -f 4m || dd if=/dev/urandom $iflag of=4m bs=4 count=1000000
test -f 6m || dd if=/dev/urandom $iflag of=6m bs=6 count=1000000
test -f 8m || dd if=/dev/urandom $iflag of=8m bs=8 count=1000000
test -f 16m || dd if=/dev/urandom $iflag of=16m bs=16 count=1000000
test -f 32m || dd if=/dev/urandom $iflag of=32m bs=32 count=1000000
test -f 64m || dd if=/dev/urandom $iflag of=64m bs=64 count=1000000
