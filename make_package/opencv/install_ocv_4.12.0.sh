#!/bin/bash
set -euo pipefail

# 如果 SKIP_CLONE 被设为非空值，则跳过 setup_repo 调用
: "${SKIP_CLONE:=}"

source setup_repo.sh

# === Main ===
work_dir=$(pwd)
tag="4.12.0"

if [[ -z "$SKIP_CLONE" ]]; then
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
fi

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
    -DOPENCV_CONFIG_INSTALL_PATH="cmake"
    #-DOPENCV_EXTRA_MODULES_PATH="$contrib_dir/modules"
)
