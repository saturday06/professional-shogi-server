#!/bin/sh

set -eux

if [ $(uname -s) = "Linux" ]; then
  iflag='iflag=fullblock'
else
  iflag=
fi
dd if=/dev/urandom $iflag of=4k bs=4 count=1000
dd if=/dev/urandom $iflag of=8k bs=8 count=1000
dd if=/dev/urandom $iflag of=16k bs=16 count=1000
dd if=/dev/urandom $iflag of=32k bs=32 count=1000
dd if=/dev/urandom $iflag of=64k bs=64 count=1000
dd if=/dev/urandom $iflag of=128k bs=128 count=1000
dd if=/dev/urandom $iflag of=256k bs=256 count=1000
dd if=/dev/urandom $iflag of=512k bs=512 count=1000
dd if=/dev/urandom $iflag of=768k bs=768 count=1000
dd if=/dev/urandom $iflag of=1m bs=1 count=1000000
dd if=/dev/urandom $iflag of=2m bs=2 count=1000000
dd if=/dev/urandom $iflag of=3m bs=3 count=1000000
dd if=/dev/urandom $iflag of=4m bs=4 count=1000000
dd if=/dev/urandom $iflag of=6m bs=6 count=1000000
dd if=/dev/urandom $iflag of=8m bs=8 count=1000000
dd if=/dev/urandom $iflag of=16m bs=16 count=1000000
dd if=/dev/urandom $iflag of=32m bs=32 count=1000000
dd if=/dev/urandom $iflag of=64m bs=64 count=1000000
