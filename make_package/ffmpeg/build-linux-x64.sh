#!/bin/bash

source checkout_ffmpeg_n7.0.3.sh

set -x

# sudo apt-get install -y nasm

build_dir="$work_dir/build-linux-x64"

# Clean build
[ -d "$build_dir" ] && rm -rf "$build_dir"

: "${ZZPKG_ROOT:=$HOME/.zzpkg}"

mkdir -p "$build_dir"
pushd "$build_dir"
../ffmpeg/configure \
    --prefix="$ZZPKG_ROOT/$pkg_name/$version/linux-x64" \
    --disable-everything \
    --enable-decoder=h264,aac \
    --enable-parser=h264,aac \
    --enable-demuxer=mp4,mov \
    --enable-protocol=file \
    --disable-network \
    --disable-hwaccels \
    --disable-doc \
    --disable-shared \
    --enable-static \
    --enable-pic \
    --disable-x86asm \
    --disable-inline-asm
make
make install
popd
