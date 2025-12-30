#!/bin/bash

source checkout_glfw_3.4.sh

set -x

build_dir="$work_dir/build-linux-x64"

# Clean build
# [ -d "$build_dir" ] && rm -rf "$build_dir"

CMAKE_GENERATOR_OPTIONS=(
      -G"Ninja"
)

: "${ZZPKG_ROOT:=$HOME/.zzpkg}"
install_dir="$ZZPKG_ROOT/$pkg_name/$version/linux-x64"
cmake "${CMAKE_GENERATOR_OPTIONS[@]}" "${CMAKE_OPTIONS[@]}" \
      -DCMAKE_INSTALL_PREFIX="$install_dir" \
      -DCMAKE_BUILD_TYPE=Release \
      -S "$source_dir" -B "$build_dir" -Wno-deprecated
cmake --build "$build_dir" --config Release
cmake --build "$build_dir" --target install --config Release
