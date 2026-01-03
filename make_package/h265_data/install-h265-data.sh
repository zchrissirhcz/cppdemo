#!/bin/bash
set -euo pipefail

# 如果 SKIP_CLONE 被设为非空值，则跳过 checkout_repo 调用
: "${SKIP_CLONE:=}"

source ../checkout_repo.sh

# === Main ===
work_dir=$(pwd)
branch="main"
version="0.1"
pkg_name="h265_data"
source_dir="$work_dir/cb315"

if [[ -z "$SKIP_CLONE" ]]; then
    checkout_repo "cb315" \
        "https://gitcode.com/open-source-toolkit/cb315.git" \
        "" \
        "$work_dir/cb315" \
        "$branch"
fi

# 使用 7z 解压，它对中文支持更好
if command -v 7z &> /dev/null; then
    7z x -y "${source_dir}/h265测试文件.zip" -o"${source_dir}/h265_data"
else
    # 如果没有 7z，尝试使用 unzip 并设置 locale
    export LANG=zh_CN.GBK
    export LC_ALL=zh_CN.GBK
    unzip -O GBK -o "${source_dir}/h265测试文件.zip" -d "${source_dir}/h265_data" || \
    unzip -O CP936 -o "${source_dir}/h265测试文件.zip" -d "${source_dir}/h265_data" || \
    unzip -o "${source_dir}/h265测试文件.zip" -d "${source_dir}/h265_data"
fi

: "${ZZPKG_ROOT:=$HOME/.zzpkg}"
DST_DIR="${ZZPKG_ROOT}/h265_data/${version}"
mkdir -p "${DST_DIR}"

cp "${source_dir}/h265_data/"* "${DST_DIR}/"
echo "✅ H.265 test data installed to: ${DST_DIR}"