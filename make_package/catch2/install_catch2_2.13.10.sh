#!/bin/bash
# 安装 Catch2 头文件到本地 zzpkg 目录
set -euo pipefail

: "${SKIP_CLONE:=}"

source ../checkout_repo.sh

# === Main ===
work_dir=$(pwd)
tag="v2.13.10"
version="2.13.10"
pkg_name="catch2"
source_dir="$work_dir/Catch2"

if [[ -z "$SKIP_CLONE" ]]; then
    checkout_repo "Catch2" \
        "https://github.com/catchorg/Catch2.git" \
        "https://gitee.com/codebeefflyee/Catch2.git" \
        "$source_dir" \
        "$tag"
fi

: "${ZZPKG_ROOT:=$HOME/.zzpkg}"

# Catch2 v2.x 只需复制单头文件，无需 CMake 构建
mkdir -p ${ZZPKG_ROOT}/catch2/${version}/inc/catch2
cp ${source_dir}/single_include/catch2/catch.hpp ${ZZPKG_ROOT}/catch2/${version}/inc/catch2/catch.hpp