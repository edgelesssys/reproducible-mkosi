#!/usr/bin/env bash

set -euo pipefail

rm -rf build*

sudo mkosi --debug --distribution=fedora
mv build build-old
sudo mkosi --debug --distribution=fedora

sudo systemd-dissect --mtree build/image.raw > build/mtree
sudo systemd-dissect --mtree build-old/image.raw > build-old/mtree

for part in "root" "verity" "efi"; do
    extract ${part} build/image.raw build/${part}
    extract ${part} build-old/image.raw build-old/${part}
done

objcopy -O binary --only-section=.cmdline build/image.efi build/cmdline
objcopy -O binary --only-section=.cmdline build-old/image.efi build-old/cmdline

veritysetup dump build/verity
veritysetup dump build-old/verity

unzstd build/image-initrd.cpio.zst
unzstd build-old/image-initrd.cpio.zst

diff build*/mtree
