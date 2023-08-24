#!/usr/bin/env bash

set -euo pipefail

# https://www.freedesktop.org/wiki/Specifications/DiscoverablePartitionsSpec/
readonly root_partition_x86_64="4f68bce3-e8cd-4db1-96e7-fbcaf984b709"
readonly root_verity_partition_x86_64="2c7357ed-ebd2-46d9-aec1-23d437ec2bf5"

function extract_partition() {
    local image=$1
    local target=$2
    local partitionUUID=$3

    partitiontable=$(sfdisk -J "${image}")
    sectorsize=$(jq -r '.partitiontable.sectorsize' <<< "${partitiontable}")
    verityPart=$(jq -r ".partitiontable.partitions[] | select(.type | ascii_downcase == \"${partitionUUID}\")" <<< "${partitiontable}")
    verityStart=$(jq -r '.start' <<< "${verityPart}")
    veritySize=$(jq -r '.size' <<< "${verityPart}")

    echo "Verity partition starts at ${verityStart} and is ${veritySize} sectors long, sector size is ${sectorsize}"

    dd if="${image}" of="${target}" bs="${sectorsize}" skip="${verityStart}" count="${veritySize}" status=progress
}

case "${1}" in
    verity)
        extract_partition "${2}" "${3}" "${root_verity_partition_x86_64}"
        ;;
    root)
        extract_partition "${2}" "${3}" "${root_partition_x86_64}"
        ;;
    *)
        echo "Usage: $0 [verity|root] <image> <target>"
        exit 1
        ;;
esac
