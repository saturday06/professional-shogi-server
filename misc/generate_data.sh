#!/bin/sh

set -eux

dd if=/dev/urandom iflag=fullblock of=4k bs=4 count=1000
dd if=/dev/urandom iflag=fullblock of=8k bs=8 count=1000
dd if=/dev/urandom iflag=fullblock of=16k bs=16 count=1000
dd if=/dev/urandom iflag=fullblock of=32k bs=32 count=1000
dd if=/dev/urandom iflag=fullblock of=64k bs=64 count=1000
dd if=/dev/urandom iflag=fullblock of=128k bs=128 count=1000
dd if=/dev/urandom iflag=fullblock of=256k bs=256 count=1000
dd if=/dev/urandom iflag=fullblock of=512k bs=512 count=1000
dd if=/dev/urandom iflag=fullblock of=768k bs=768 count=1000
dd if=/dev/urandom iflag=fullblock of=1m bs=1 count=1000000
dd if=/dev/urandom iflag=fullblock of=2m bs=2 count=1000000
dd if=/dev/urandom iflag=fullblock of=3m bs=3 count=1000000
dd if=/dev/urandom iflag=fullblock of=4m bs=4 count=1000000
dd if=/dev/urandom iflag=fullblock of=6m bs=6 count=1000000
dd if=/dev/urandom iflag=fullblock of=8m bs=8 count=1000000
dd if=/dev/urandom iflag=fullblock of=16m bs=16 count=1000000
dd if=/dev/urandom iflag=fullblock of=32m bs=32 count=1000000
dd if=/dev/urandom iflag=fullblock of=64m bs=64 count=1000000
