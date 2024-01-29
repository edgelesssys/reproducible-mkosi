#!/usr/bin/env bash

set -euo pipefail

rm -rf build*

#
# build two images
#

mkosi --debug --distribution="${1}"
mv build build-a

mkosi --debug --distribution="${1}"
mv build build-b

# remove symlinks
find build-a -type l -delete
find build-b -type l -delete

#
# extract all the things
#

# shellcheck disable=SC2024
sudo env PATH="$PATH" systemd-dissect --mtree build-a/system.raw > build-a/mtree
# shellcheck disable=SC2024
sudo env PATH="$PATH" systemd-dissect --mtree build-b/system.raw > build-b/mtree

for part in "root" "verity" "efi"; do
    extract ${part} build-a/system.raw build-a/${part}
    extract ${part} build-b/system.raw build-b/${part}
done

objcopy -O binary --only-section=.cmdline build-a/system.efi build-a/cmdline
objcopy -O binary --only-section=.cmdline build-b/system.efi build-b/cmdline

veritysetup dump build-a/verity
veritysetup dump build-b/verity

if [[ -f build-a/initrd.cpio.zstd ]]; then
    unzstd build-a/initrd.cpio.zstd
    unzstd build-b/initrd.cpio.zstd
else
    # for mkosi < 19
    unzstd build-a/initrd.cpio.zst
    unzstd build-b/initrd.cpio.zst
fi

#
# check the result
#

echo
exitcode=0

touch build-{a,b}/{initrd,system}.manifest
if ! diff build*/initrd.manifest; then
  exitcode=1
fi
if ! diff build*/system.manifest; then
  exitcode=1
fi

if ! diff build*/mtree; then
  exitcode=1
fi

sumsA=$(sha256sum build-a/* | rev | sort | rev)
sumsB=$(sha256sum build-b/* | rev | sort | rev)

while IFS= read -r new && IFS= read -r old <&3; do
  sumA=$(echo "${old}" | cut -d' ' -f1)
  sumB=$(echo "${new}" | cut -d' ' -f1)
  if [[ "${sumA}" != "${sumB}" ]]; then
    echo "${new}"
    echo "${old}"
    echo
    exitcode=1
  fi
done <<< "${sumsA}" 3<<< "${sumsB}"

exit "${exitcode}"
