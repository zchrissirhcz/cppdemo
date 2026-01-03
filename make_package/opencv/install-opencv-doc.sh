#!/bin/bash
set -euo pipefail

# if not exist 4.12.0.zip, download it
if [[ ! -f 4.12.0.zip ]]; then
    echo "Downloading OpenCV 4.12.0 documentation..."
    curl -fSL -o 4.12.0.zip https://docs.opencv.org/4.12.0.zip
fi

# === Main ===
: "${ZZPKG_ROOT:=$HOME/.zzpkg}"

DST_DIR="${ZZPKG_ROOT}/opencv-doc"
mkdir -p $DST_DIR
unzip -o 4.12.0.zip -d $DST_DIR
