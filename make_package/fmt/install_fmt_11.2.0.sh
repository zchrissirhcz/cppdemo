#!/bin/bash
set -euo pipefail

: "${SKIP_CLONE:=}"

source ../checkout_repo.sh

# === Main ===
work_dir=$(pwd)
tag="11.2.0"
version="11.2.0"
pkg_name="fmt"
source_dir="$work_dir/fmt"

if [[ -z "$SKIP_CLONE" ]]; then
    checkout_repo "fmt" \
        "https://github.com/fmtlib/fmt.git" \
        "https://gitee.com/mirrors/fmt.git" \
        "$source_dir" \
        "$tag"
fi

: "${ZZPKG_ROOT:=$HOME/.zzpkg}"

# copy header files
mkdir -p ${ZZPKG_ROOT}/fmt/11.2.0
cp -R ${source_dir}/include ${ZZPKG_ROOT}/fmt/11.2.0/inc
