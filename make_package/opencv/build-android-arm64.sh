#!/bin/bash

source checkout_ocv_4.12.0.sh

set -x

build_dir="$work_dir/build-android"

: "${ZZPKG_ROOT:=$HOME/.zzpkg}"
install_dir="$ZZPKG_ROOT/$pkg_name/$version/android-arm64"

ANDROID_NDK="/C/soft/android-ndk/r27c"

CMAKE_OPTIONS+=(
    -G"Ninja"
    -DANDROID_SDK=OFF
    -DBUILD_JAVA=OFF
    -DBUILD_ANDROID_EXAMPLES=OFF
    -DOPENCV_BIN_INSTALL_PATH="bin"
    -DOPENCV_LIB_INSTALL_PATH="libs"
    -DOPENCV_LIB_ARCHIVE_INSTALL_PATH="libs"
    -DOPENCV_3P_LIB_INSTALL_PATH="libs/3rdparty"
    -DOPENCV_CONFIG_INSTALL_PATH="cmake"
    -DOPENCV_INCLUDE_INSTALL_PATH="include"
    -DOPENCV_OTHER_INSTALL_PATH="etc"
    -DOPENCV_SAMPLES_SRC_INSTALL_PATH="samples"
)

cmake -DCMAKE_TOOLCHAIN_FILE="$ANDROID_NDK/build/cmake/android.toolchain.cmake" \
      -DANDROID_ABI="arm64-v8a" \
      -DANDROID_PLATFORM=android-21 \
      "${CMAKE_OPTIONS[@]}" \
      -DCMAKE_INSTALL_PREFIX="$install_dir" \
      -DCMAKE_BUILD_TYPE=Release \
      -S "$source_dir" -B "$build_dir" -Wno-deprecated
    
cmake --build "$build_dir" --config Release
cmake --build "$build_dir" --target install --config Release