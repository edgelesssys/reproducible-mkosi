#!/usr/bin/env bash

set -euo pipefail

distro=$(awk -F= '$1 == "ID" {print $2}' /etc/os-release)
sudo=""
if [ "${distro}" = "nixos" ]; then
    sudo="sudo" # mkosi needs sudo on NixOS
fi

rm -rf build*

${sudo} mkosi --debug --distribution=fedora
mv build build-old
${sudo} mkosi --debug --distribution=fedora

${sudo} systemd-dissect --mtree build/system.raw > build/mtree
${sudo} systemd-dissect --mtree build-old/system.raw > build-old/mtree

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
