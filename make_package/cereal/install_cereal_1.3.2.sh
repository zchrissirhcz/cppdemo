#!/bin/bash
set -euo pipefail

: "${SKIP_CLONE:=}"

source ../checkout_repo.sh

# === Main ===
work_dir=$(pwd)
tag="v1.3.2"
version="1.3.2"
pkg_name="cereal"
source_dir="$work_dir/cereal"

if [[ -z "$SKIP_CLONE" ]]; then
    checkout_repo "cereal" \
        "https://github.com/USCiLab/cereal.git" \
        "https://gitee.com/mirrors/cereal.git" \
        "$source_dir" \
        "$tag"
fi

: "${ZZPKG_ROOT:=$HOME/.zzpkg}"

# copy header files
mkdir -p ${ZZPKG_ROOT}/cereal/${version}
cp -R ${source_dir}/include ${ZZPKG_ROOT}/cereal/${version}/inc
