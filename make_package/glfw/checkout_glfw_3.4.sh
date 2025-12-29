#!/bin/bash
set -euo pipefail

# 如果 SKIP_CLONE 被设为非空值，则跳过 checkout_repo 调用
: "${SKIP_CLONE:=}"

source ../checkout_repo.sh

# === Main ===
work_dir=$(pwd)
tag="3.4"
version="$tag"
pkg_name="glfw"
source_dir="$work_dir/glfw"

if [[ -z "$SKIP_CLONE" ]]; then
    checkout_repo "glfw" \
            "https://github.com/glfw/glfw.git" \
            "https://gitee.com/mirrors/glfw.git" \
            "$work_dir/glfw" \
            "$tag"
fi

CMAKE_OPTIONS=(
    -DCMAKE_DEBUG_POSTFIX="_d"
)
