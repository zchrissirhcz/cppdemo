#!/bin/bash

source checkout_pystring_1.1.4.sh

set -x

build_dir="$work_dir/build-mac-aarch64"

# Clean build
# [ -d "$build_dir" ] && rm -rf "$build_dir"

CMAKE_OPTIONS=(
  -DBUILD_SHARED_LIBS=OFF
  -DCMAKE_POLICY_VERSION_MINIMUM=3.5
  -DCMAKE_DEBUG_POSTFIX="_d"
)

CMAKE_GENERATOR_OPTIONS=(
    -G"Ninja"
)

: "${ZZPKG_ROOT:=$HOME/.zzpkg}"
install_dir="$ZZPKG_ROOT/$pkg_name/$version/mac-aarch64-static"
cmake "${CMAKE_GENERATOR_OPTIONS[@]}" "${CMAKE_OPTIONS[@]}" \
    -DCMAKE_INSTALL_PREFIX="$install_dir" \
    -DCMAKE_BUILD_TYPE=Release \
    -S "$source_dir" -B "$build_dir" -Wno-deprecated
cmake --build "$build_dir" --config Release
cmake --build "$build_dir" --target install --config Release
