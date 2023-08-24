#!/usr/bin/env bash

set -euo pipefail

# https://www.freedesktop.org/wiki/Specifications/DiscoverablePartitionsSpec/
readonly root_partition_x86="44479540-f297-41b2-9af7-d131d5f0458a"
readonly root_partition_x86_64="4f68bce3-e8cd-4db1-96e7-fbcaf984b709"
readonly root_partition_arm="69dad710-2ce4-4e3c-b16c-21a1d49abed3"
readonly root_partition_arm64="b921b045-1df0-41c3-af44-4c6f280d3fae"
readonly root_partition_ia64="993d8d3d-f80e-4225-855a-9daf8ed7ea97"
readonly root_partition_UUIDs="${root_partition_x86},${root_partition_x86_64},${root_partition_arm},${root_partition_arm64},${root_partition_ia64}"

readonly root_verity_partition_x86="d13c5d3b-b5d1-422a-b29f-9454fdc89d76"
readonly root_verity_partition_x86_64="2c7357ed-ebd2-46d9-aec1-23d437ec2bf5"
readonly root_verity_partition_arm="7386cdf2-203c-47a9-a498-f2ecce45a2d6"
readonly root_verity_partition_arm64="df3300ce-d69f-4c92-978c-9bfb0f38d820"
readonly root_verity_partition_ia64="86ed10d5-b607-45bb-8957-d350f23d0571"
readonly root_verity_partition_UUIDs="${root_verity_partition_x86},${root_verity_partition_x86_64},${root_verity_partition_arm},${root_verity_partition_arm64},${root_verity_partition_ia64}"

readonly home_partition="933ac7e1-2eb4-4f13-b844-0e14e2aef915"
readonly server_data_partition="3b8f8425-20e0-4f3b-907f-1a25a76f98e8"
readonly swap_partition="0657fd6d-a4ab-43c4-84e5-0933c84b4f4f"
readonly efi_system_partition="c12a7328-f81f-11d2-ba4b-00a0c93ec93b"
readonly other_data_partition="0fc63daf-8483-4772-8e79-3d69d8477de4"

function extract_partition() {
    local image=$1
    local target=$2
    local partitionUUIDs=$3

    partitiontable=$(sfdisk -J "${image}")
    sectorsize=$(jq -r '.partitiontable.sectorsize' <<< "${partitiontable}")
    verityPart=$(
        jq -r ".partitiontable.partitions[] |
            select(
                .type |
                ascii_downcase as \$type |
                \"${partitionUUIDs}\" |
                split(\",\") as \$uuids |
                any(
                    \$uuids[]; . == \$type
                )
            )" <<< "${partitiontable}"
    )
    verityStart=$(jq -r '.start' <<< "${verityPart}")
    veritySize=$(jq -r '.size' <<< "${verityPart}")

    echo "Verity partition starts at ${verityStart} and is ${veritySize} sectors long, sector size is ${sectorsize}"

    dd if="${image}" of="${target}" bs="${sectorsize}" skip="${verityStart}" count="${veritySize}" status=progress
}

function main() {
    local uuids
    case "${1}" in
        verity)
            uuids="${root_verity_partition_UUIDs}"
            ;;
        root)
            uuids="${root_partition_UUIDs}"
            ;;
        home)
            uuids="${home_partition}"
            ;;
        server)
            uuids="${server_data_partition}"
            ;;
        swap)
            uuids="${swap_partition}"
            ;;
        efi)
            uuids="${efi_system_partition}"
            ;;
        other)
            uuids="${other_data_partition}"
            ;;
        *)
            echo "Usage: $0 [verity|root] <image> <target>"
            exit 1
            ;;
    esac
    extract_partition "${2}" "${3}" "${uuids}"
}

main "$@"
