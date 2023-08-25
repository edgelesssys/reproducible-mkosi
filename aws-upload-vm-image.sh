#!/usr/bin/env bash

set -eou pipefail

region=eu-central-1
S3Bucket=constellation-ci
S3Path=paul/
iamgepath=$(realpath "$1")
imagename=$(basename "$1")

function echoerr() {
    echo "$@" 1>&2
}

function uploadImage() {
    aws s3 cp "$iamgepath" "s3://${S3Bucket}/${S3Path}/${imagename}"
}

function importSnapshot() {
    out=$(
        aws ec2 import-snapshot \
            --region "${region}" \
            --description "${imagename%.*}" \
            --disk-container "Format=VHD,UserBucket={S3Bucket=${S3Bucket},S3Key=${S3Path}/${imagename}}"
    )
    jq -r '.ImportTaskId' <<< "$out"
}

function waitForTask() {
    local taskID=$1

    while true; do
        out=$(
            aws ec2 describe-import-snapshot-tasks \
                --region "${region}" \
                --import-task-ids "$taskID"
        )
        status=$(jq -r '.ImportSnapshotTasks[0].SnapshotTaskDetail.Status' <<< "$out")
        case "$status" in
        completed)
            echoerr "Task completed"
            break
            ;;
        pending | active)
            echoerr "Task still in progress..."
            sleep 10
            ;;
        *)
            echoerr "Task failed with status ${status}"
            exit 1
            ;;
        esac
    done

}
