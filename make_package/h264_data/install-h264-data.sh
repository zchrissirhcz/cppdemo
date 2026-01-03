#!/bin/bash
set -euo pipefail

# 如果 SKIP_CLONE 被设为非空值，则跳过 checkout_repo 调用
: "${SKIP_CLONE:=}"

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "${SCRIPT_DIR}/../checkout_repo.sh"
source "${SCRIPT_DIR}/../zip_utils.sh"

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

zip_file="${source_dir}/h264测试视频.zip"
extract_root="${source_dir}/h264_data"

if [[ ! -f "${zip_file}" ]]; then
    echo "ERROR: zip not found: ${zip_file}" >&2
    exit 1
fi

zzpkg_extract_zip_cross_platform "${zip_file}" "${extract_root}"

: "${ZZPKG_ROOT:=$HOME/.zzpkg}"
DST_DIR="${ZZPKG_ROOT}/h264_data/${version}"
mkdir -p "${DST_DIR}"

# 复制文件，去掉 zip 内部的顶层目录（中文名在不同系统/工具下可能不一致）
payload_dir=$(zzpkg_find_payload_dir "${extract_root}" "h264测试视频" "*.h264")
if [[ -z "${payload_dir}" || ! -d "${payload_dir}" ]]; then
    echo "ERROR: failed to locate extracted payload under: ${extract_root}" >&2
    exit 1
fi

shopt -s nullglob
files=("${payload_dir}"/*)
if (( ${#files[@]} == 0 )); then
    echo "ERROR: no files found in payload dir: ${payload_dir}" >&2
    exit 1
fi

cp -f "${files[@]}" "${DST_DIR}/"

echo "✅ H.264 test data installed to: ${DST_DIR}"