#!/bin/bash

source checkout_ffmpeg_n7.0.3.sh

set -x

build_dir="$work_dir/build-mac-aarch64"

# Clean build
# [ -d "$build_dir" ] && rm -rf "$build_dir"

: "${ZZPKG_ROOT:=$HOME/.zzpkg}"

mkdir -p "$build_dir"
pushd "$build_dir"
../ffmpeg/configure \
    --prefix="$ZZPKG_ROOT/$pkg_name/$version/mac-aarch64" \
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
    --enable-pic
make
make install
popd
