#!/bin/bash
set -euo pipefail

: "${SKIP_CLONE:=}"

source ../checkout_repo.sh

# === Main ===
work_dir=$(pwd)
tag="v1.5.14"
version="1.5.14"
pkg_name="ghc-filesystem"
source_dir="$work_dir/filesystem"

if [[ -z "$SKIP_CLONE" ]]; then
    checkout_repo "ghc-filesystem" \
        "https://github.com/gulrak/filesystem.git" \
        "https://gitee.com/LonelyRyan-lazy/filesystem.git" \
        "$source_dir" \
        "$tag"
fi

: "${ZZPKG_ROOT:=$HOME/.zzpkg}"

# copy header files
mkdir -p ${ZZPKG_ROOT}/ghc-filesystem/1.5.14
cp -R ${source_dir}/include ${ZZPKG_ROOT}/ghc-filesystem/1.5.14/inc