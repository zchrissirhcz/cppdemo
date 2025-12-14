#!/bin/bash
set -euo pipefail

# 如果 SKIP_CLONE 被设为非空值，则跳过 checkout_repo 调用
: "${SKIP_CLONE:=}"

source ../checkout_repo.sh

# === Main ===
work_dir=$(pwd)
branch="master"
version="$branch"
pkg_name="ncnn"
source_dir="$work_dir/ncnn"

if [[ -z "$SKIP_CLONE" ]]; then
    checkout_repo "ncnn" \
            "https://github.com/Tencent/ncnn.git" \
            "https://gitee.com/Tencent/ncnn.git" \
            "$work_dir" \
            "$branch"
fi

CMAKE_OPTIONS=(
    -DCMAKE_DEBUG_POSTFIX="_d"
)
