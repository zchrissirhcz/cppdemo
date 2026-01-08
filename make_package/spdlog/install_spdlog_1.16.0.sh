#!/bin/bash
set -euo pipefail

# 如果 SKIP_CLONE 被设为非空值，则跳过 checkout_repo 调用
: "${SKIP_CLONE:=}"

source ../checkout_repo.sh

# === Main ===
work_dir=$(pwd)
tag="v1.16.0"
version="1.16.0"
pkg_name="spdlog"
source_dir="$work_dir/spdlog"

if [[ -z "$SKIP_CLONE" ]]; then
    checkout_repo "spdlog" \
        "https://github.com/gabime/spdlog.git" \
        "https://gitee.com/mirrors_nigels-com/spdlog.git" \
        "$source_dir" \
        "$tag"
fi

: "${ZZPKG_ROOT:=$HOME/.zzpkg}"

# copy header files
mkdir -p ${ZZPKG_ROOT}/spdlog/${version}
cp -R ${source_dir}/include ${ZZPKG_ROOT}/spdlog/${version}/inc
