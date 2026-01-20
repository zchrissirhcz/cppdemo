#!/bin/bash
set -euo pipefail

# 如果 SKIP_CLONE 被设为非空值，则跳过 checkout_repo 调用
: "${SKIP_CLONE:=}"

source ../checkout_repo.sh

# === Main ===
work_dir=$(pwd)
tag="v1.1.4"
version="1.1.4"
sha="a9df4d1" # as patch on v1.1.4 which fix CMakeLists.txt
pkg_name="pystring"
source_dir="$work_dir/pystring"

if [[ -z "$SKIP_CLONE" ]]; then
    checkout_repo "pystring" \
        "https://github.com/imageworks/pystring.git" \
        "https://gitee.com/waynewangV5/pystring.git" \
        "$work_dir/pystring" \
        "$sha"
fi

# === Patch ===
cp CMakeLists.txt pystring/
mkdir -p pystring/cmake
cp pystringConfig.cmake.in pystring/cmake/