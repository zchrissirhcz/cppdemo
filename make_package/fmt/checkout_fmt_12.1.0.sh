#!/bin/bash
set -euo pipefail

: "${SKIP_CLONE:=}"

source ../checkout_repo.sh

# === Main ===
work_dir=$(pwd)
tag="12.1.0"
version="12.1.0"
pkg_name="fmt"
source_dir="$work_dir/fmt"

if [[ -z "$SKIP_CLONE" ]]; then
    checkout_repo "fmt" \
        "https://github.com/fmtlib/fmt.git" \
        "https://gitee.com/mirrors/fmt.git" \
        "$source_dir" \
        "$tag"
fi

CMAKE_OPTIONS=(
    -DFMT_UNICODE=OFF
    -DFMT_TEST=OFF
    -DFMT_DEBUG_POSTFIX=_d
    -DFMT_UNICODE=ON
)
