#!/bin/bash
set -euo pipefail

: "${SKIP_CLONE:=}"

source ../checkout_repo.sh

# === Main ===
work_dir=$(pwd)
tag="v2.6.1"
version="2.6.1"
pkg_name="CLI11"
source_dir="$work_dir/CLI11"

if [[ -z "$SKIP_CLONE" ]]; then
    checkout_repo "CLI11" \
        "https://github.com/CLIUtils/CLI11.git" \
        "https://gitee.com/async_github/CLI11.git" \
        "$source_dir" \
        "$tag"
fi

: "${ZZPKG_ROOT:=$HOME/.zzpkg}"

CMAKE_OPTIONS=(
    -DCLI11_BUILD_TESTS=OFF
    -DCLI11_BUILD_EXAMPLES=OFF
    -DCLI11_SINGLE_FILE=ON
    -DCMAKE_INSTALL_PREFIX=build/install
    -DCMAKE_BUILD_TYPE=Release
)

cmake -S ${source_dir} -B build "${CMAKE_OPTIONS[@]}"
cmake --build build --config Release --target install
cmake --install build
mkdir -p ${ZZPKG_ROOT}/CLI11/${version}/inc/CLI
cp ./build/install/include/CLI11.hpp ${ZZPKG_ROOT}/CLI11/${version}/inc/CLI/CLI11.hpp