#!/bin/bash
set -euo pipefail

# 如果 SKIP_CLONE 被设为非空值，则跳过 checkout_repo 调用
: "${SKIP_CLONE:=}"

source ../checkout_repo.sh

# === Main ===
work_dir=$(pwd)
branch="main"
version="0.1"
pkg_name="h264_data"
source_dir="$work_dir/c59f9"

if [[ -z "$SKIP_CLONE" ]]; then
    checkout_repo "c59f9" \
        "https://gitcode.com/open-source-toolkit/c59f9.git" \
        "" \
        "$work_dir/c59f9" \
        "$branch"
fi

# 使用 7z 解压，它对中文支持更好
if command -v 7z &> /dev/null; then
    7z x -y "${source_dir}/h264测试视频.zip" -o"${source_dir}/h264_data"
else
    # 如果没有 7z，尝试使用 unzip 并设置 locale
    export LANG=zh_CN.GBK
    export LC_ALL=zh_CN.GBK
    unzip -O GBK -o "${source_dir}/h264测试视频.zip" -d "${source_dir}/h264_data" || \
    unzip -O CP936 -o "${source_dir}/h264测试视频.zip" -d "${source_dir}/h264_data" || \
    unzip -o "${source_dir}/h264测试视频.zip" -d "${source_dir}/h264_data"
fi

: "${ZZPKG_ROOT:=$HOME/.zzpkg}"
DST_DIR="${ZZPKG_ROOT}/h264_data/${version}"
mkdir -p "${DST_DIR}"

# 复制文件，去掉 h264测试视频 这层目录
cp "${source_dir}/h264_data/h264测试视频/"* "${DST_DIR}/"

echo "✅ H.264 test data installed to: ${DST_DIR}"