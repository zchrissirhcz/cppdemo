#!/bin/bash
set -euo pipefail

source setup_repo.sh

# === Main ===
work_dir=$(pwd)
tag="4.12.0"

setup_repo "opencv" \
           "https://github.com/opencv/opencv.git" \
           "https://gitee.com/opencv/opencv.git" \
           "$work_dir" \
           "$tag"

setup_repo "opencv_contrib" \
           "https://github.com/opencv/opencv_contrib.git" \
           "https://gitee.com/opencv/opencv_contrib.git" \
           "$work_dir" \
           "$tag"

# Verify directories
source_dir="$work_dir/opencv"
contrib_dir="$work_dir/opencv_contrib"
build_dir="$work_dir/build"

#install_dir="$work_dir/.pkgs/opencv/$tag/vs2022-x64"
# if ZZPKG_ROOT is not set, default to work_dir/.pkgs
: "${ZZPKG_ROOT:=$work_dir/.pkgs}"
install_dir="$ZZPKG_ROOT/opencv/$tag/vs2022-x64"

if [ ! -d "$source_dir" ] || [ ! -d "$contrib_dir/modules" ]; then
    echo "Error: Required source directories missing!" >&2
    exit 1
fi

# Clean build
# [ -d "$build_dir" ] && rm -rf "$build_dir"

#CMAKE_GENERATOR_OPTIONS=-G"Visual Studio 16 2019"
#CMAKE_GENERATOR_OPTIONS=-G"Visual Studio 15 2017 Win64"
#CMAKE_GENERATOR_OPTIONS=(-G"Visual Studio 16 2019" -A x64)
CMAKE_GENERATOR_OPTIONS=(-G"Visual Studio 17 2022" -A x64)
#CMAKE_GENERATOR_OPTIONS=(-G"Visual Studio 18 2026" -A x64)
CMAKE_OPTIONS=(
    -DBUILD_PERF_TESTS=OFF
    -DBUILD_TESTS=OFF
    -DBUILD_DOCS=OFF
    -DWITH_CUDA=OFF
    -DWITH_OPENCL=OFF
    -DBUILD_EXAMPLES=OFF
    -DINSTALL_CREATE_DISTRIB=ON
    -DOPENCV_DOWNLOAD_MIRROR_ID="gitcode"
    -DBUILD_opencv_dnn=OFF
    -DCMAKE_DEBUG_POSTFIX="_d"
    -DBUILD_opencv_world=OFF
    -DOPENCV_INSTALL_BINARIES_PREFIX=""
    #-DOPENCV_EXTRA_MODULES_PATH="$contrib_dir/modules"
)

set -x
cmake "${CMAKE_GENERATOR_OPTIONS[@]}" "${CMAKE_OPTIONS[@]}" \
      -DCMAKE_INSTALL_PREFIX="$install_dir" \
      -S "$source_dir" -B "$build_dir"

cmake --build "$build_dir" --config Debug
cmake --build "$build_dir" --target install --config Debug
cmake --build "$build_dir" --config Release
cmake --build "$build_dir" --target install --config Release