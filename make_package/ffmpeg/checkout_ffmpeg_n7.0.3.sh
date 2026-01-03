#!/bin/bash
set -euo pipefail

# 如果 SKIP_CLONE 被设为非空值，则跳过 checkout_repo 调用
: "${SKIP_CLONE:=}"

source ../checkout_repo.sh

# === Main ===
work_dir=$(pwd)
tag="n7.0.3"
version="7.0.3"
pkg_name="ffmpeg"
source_dir="$work_dir/ffmpeg"

if [[ -z "$SKIP_CLONE" ]]; then
    checkout_repo "ffmpeg" \
        "https://git.ffmpeg.org/ffmpeg.git" \
        "https://gitee.com/mirrors/ffmpeg.git" \
        "$work_dir/ffmpeg" \
        "$tag"
fi
