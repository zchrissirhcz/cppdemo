#!/bin/bash

source checkout_ocv_4.12.0.sh

set -x
# set -u  # 如果有这行，先注释掉或者正确初始化变量

sudo apt install -y libgtk2.0-dev

build_dir="$work_dir/build-linux-x64"

: "${ZZPKG_ROOT:=$HOME/.zzpkg}"

# Clean build
[ -d "$build_dir" ] && rm -rf "$build_dir"

FFMPEG_PREFIX="$ZZPKG_ROOT/ffmpeg/7.0.3/linux-x64"

# 初始化 PKG_CONFIG_PATH（防止 set -u 报错）
export PKG_CONFIG_PATH="${PKG_CONFIG_PATH:-}${PKG_CONFIG_PATH:+:}$FFMPEG_PREFIX/lib/pkgconfig"

CMAKE_GENERATOR_OPTIONS=(
    -G"Ninja"
    -DWITH_FFMPEG=ON
    -DVIDEOIO_ENABLE_PLUGINS=OFF
    
    # 方法1: 通过 CMAKE_PREFIX_PATH 让 CMake 自动查找
    -DCMAKE_PREFIX_PATH="$FFMPEG_PREFIX"
    
    # 方法2: 手动指定每个库
    -DFFMPEG_INCLUDE_DIR="$FFMPEG_PREFIX/include"
    -DFFMPEG_LIBAVCODEC="$FFMPEG_PREFIX/lib/libavcodec.a"
    -DFFMPEG_LIBAVFORMAT="$FFMPEG_PREFIX/lib/libavformat.a"
    -DFFMPEG_LIBAVUTIL="$FFMPEG_PREFIX/lib/libavutil.a"
    -DFFMPEG_LIBSWSCALE="$FFMPEG_PREFIX/lib/libswscale.a"
    -DFFMPEG_LIBSWRESAMPLE="$FFMPEG_PREFIX/lib/libswresample.a"
)

install_dir="$ZZPKG_ROOT/$pkg_name/$version/linux-x64"

cmake "${CMAKE_GENERATOR_OPTIONS[@]}" "${CMAKE_OPTIONS[@]}" \
      -DCMAKE_INSTALL_PREFIX="$install_dir" \
      -DCMAKE_BUILD_TYPE=Release \
      -S "$source_dir" -B "$build_dir" -Wno-deprecated

cmake --build "$build_dir" --config Release
cmake --build "$build_dir" --target install --config Release
