#!/usr/bin/env bash

set -euo pipefail

rm -rf build*

#
# build two images
#

mkosi --debug --distribution="${1}"
mv build build-old
mkosi --debug --distribution="${1}"

#
# extract all the things
#

# shellcheck disable=SC2024
sudo systemd-dissect --mtree build/system.raw > build/mtree
# shellcheck disable=SC2024
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

#
# check the result
#

exitcode=0

diff build*/mtree || exitcode=1 && echo

sumsNew=$(sha256sum build/* | rev | sort | rev)
sumsOld=$(sha256sum build-old/* | rev | sort | rev)

while IFS= read -r new && IFS= read -r old <&3; do
  sumOld=$(echo "${old}" | cut -d' ' -f1)
  sumNew=$(echo "${new}" | cut -d' ' -f1)
  if [[ "${sumOld}" != "${sumNew}" ]]; then
    echo "${new}"
    echo "${old}"
    echo
    exitcode=1
  fi
done <<< "${sumsNew}" 3<<< "${sumsOld}"

exit "${exitcode}"
