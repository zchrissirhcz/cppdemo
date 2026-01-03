#!/bin/bash
set -euo pipefail

: "${SKIP_CLONE:=}"

source ../checkout_repo.sh

# === Main ===
work_dir=$(pwd)
branch="master"
version="$branch"
pkg_name="mpbase-i"
source_dir="$work_dir/ArcSoft_FreeSDK_Demo"

if [[ -z "$SKIP_CLONE" ]]; then
    checkout_repo "cereal" \
        "https://github.com/smartkids77/ArcSoft_FreeSDK_Demo.git" \
        "" \
        "$source_dir" \
        "$branch"
fi

: "${ZZPKG_ROOT:=$HOME/.zzpkg}"

# copy header files
DST_DIR=${ZZPKG_ROOT}/mpbase-i/0.1/inc
mkdir -p ${DST_DIR}
cp $source_dir/ArcFace/QT/FRDemo/amcomdef.h $DST_DIR/
cp $source_dir/ArcFace/QT/FRDemo/merror.h $DST_DIR/
cp $source_dir/ArcFace/QT/FRDemo/asvloffscreen.h $DST_DIR/
