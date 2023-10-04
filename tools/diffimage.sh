#!/usr/bin/env bash

set -euo pipefail

rm -rf build*

#
# build two images
#

mkosi --debug --distribution="${1}" --output-dir="build-a"
if [[ ! -d "build-a" ]]; then
    mv build build-a
fi
mkosi --debug --distribution="${1}" --output-dir="build-b"
if [[ ! -d "build-b" ]]; then
    mv build build-b
fi

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

unzstd build-a/initrd.cpio.zst
unzstd build-b/initrd.cpio.zst

#
# check the result
#

echo
exitcode=0

diff build*/initrd.manifest || (exitcode=1 && echo)
diff build*/system.manifest || (exitcode=1 && echo)

diff build*/mtree || (exitcode=1 && echo)

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
