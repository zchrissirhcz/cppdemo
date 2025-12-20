#!/bin/bash
set -euo pipefail

source ../checkout_repo.sh

# === Main ===
: "${ZZPKG_ROOT:=$HOME/.zzpkg}"

tag="4.12.0"
checkout_repo "opencv" \
      "https://github.com/opencv/opencv.git" \
      "https://gitee.com/opencv/opencv.git" \
      "${ZZPKG_ROOT}/opencv-src/$tag" \
      "$tag"

checkout_repo "opencv_contrib" \
      "https://github.com/opencv/opencv_contrib.git" \
      "https://gitee.com/opencv/opencv_contrib.git" \
      "${ZZPKG_ROOT}/opencv-contrib-src/$tag" \
      "$tag"