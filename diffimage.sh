#!/usr/bin/env bash

set -euo pipefail

rm -rf build*

mkosi --debug --distribution="${1}"
mv build build-old
mkosi --debug --distribution="${1}"

sudo systemd-dissect --mtree build/system.raw > build/mtree
sudo systemd-dissect --mtree build-old/system.raw > build-old/mtree

for part in "root" "verity" "efi"; do
    extract ${part} build/system.raw build/${part}
    extract ${part} build-old/system.raw build-old/${part}
done

objcopy -O binary --only-section=.cmdline build/system.efi build/cmdline
objcopy -O binary --only-section=.cmdline build-old/system.efi build-old/cmdline

veritysetup dump build/verity
veritysetup dump build-old/verity

unzstd build/initrd.cpio.zst
unzstd build-old/initrd.cpio.zst

diff build*/mtree

sha256sum build*/* | rev | sort | rev
