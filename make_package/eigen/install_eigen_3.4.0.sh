#!/bin/bash
set -euo pipefail

# 如果 SKIP_CLONE 被设为非空值，则跳过 checkout_repo 调用
: "${SKIP_CLONE:=}"

source ../checkout_repo.sh

# === Main ===
work_dir=$(pwd)
tag="3.4.0"
version="$tag"
pkg_name="eigen"
source_dir="$work_dir/eigen"

if [[ -z "$SKIP_CLONE" ]]; then
    checkout_repo "eigen" \
            "https://gitlab.com/libeigen/eigen.git" \
            "https://gitee.com/logeexpluoqi/eigen.git" \
            "$source_dir" \
            "$tag"
fi

: "${ZZPKG_ROOT:=$HOME/.zzpkg}"

# copy header files
mkdir -p ${ZZPKG_ROOT}/Eigen/3.4.0/inc
cp -R ${source_dir}/Eigen ${ZZPKG_ROOT}/Eigen/3.4.0/inc
mkdir -p ${ZZPKG_ROOT}/Eigen/3.4.0/inc/unsupported
cp -R ${source_dir}/unsupported/Eigen ${ZZPKG_ROOT}/Eigen/3.4.0/inc/unsupported
