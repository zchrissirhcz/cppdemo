#!/bin/bash
set -euo pipefail

source ../checkout_repo.sh

# === Main ===
work_dir=$(pwd)

# clone it from network
checkout_repo "imgui" \
        "https://github.com/ocornut/imgui.git" \
        "https://gitee.com/mirrors/imgui.git" \
        "$work_dir/imgui" \
        "master"

# specify branch and clone it to ZZPKG_ROOT/imgui/branch
: "${ZZPKG_ROOT:=$HOME/.zzpkg}"
tag="v1.92.5"
version="1.92.5"
checkout_repo "imgui" \
        "https://github.com/ocornut/imgui.git" \
        "${work_dir}/imgui" \
        "$ZZPKG_ROOT/imgui-src/$version" \
        "$tag"
