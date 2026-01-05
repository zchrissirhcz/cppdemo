#!/bin/bash
set -euo pipefail

# === Main ===
VERSION="4.12.0"
: "${ZZPKG_ROOT:=$HOME/.zzpkg}"
: "${ZZPKG_CLEAN_INSTALL:=false}"

DST_DIR="${ZZPKG_ROOT}/opencv-doc/${VERSION}"

# Check if already installed
if [[ -d "$DST_DIR" && -f "$DST_DIR/index.html" ]]; then
    if [[ "$ZZPKG_CLEAN_INSTALL" == "true" ]]; then
        echo "Removing existing installation..."
        rm -rf "$DST_DIR"
    else
        echo "OpenCV ${VERSION} already installed. Skipping download and extraction."
        echo "Set ZZPKG_CLEAN_INSTALL=true to reinstall."
        
        # Still create shortcut on Windows
        if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
            echo ""
            bash "$(dirname "$0")/create-windows-shortcuts.sh"
        fi
        
        echo "Documentation location: $DST_DIR"
        exit 0
    fi
fi

# if not exist 4.12.0.zip, download it
if [[ ! -f ${VERSION}.zip ]]; then
    echo "Downloading OpenCV ${VERSION} documentation..."
    curl -fSL -o ${VERSION}.zip https://docs.opencv.org/${VERSION}.zip
fi

echo "Extracting documentation..."
TEMP_DIR=$(mktemp -d)
unzip -q ${VERSION}.zip -d "$TEMP_DIR"

# Move contents from VERSION subdirectory to DST_DIR
mkdir -p "$DST_DIR"
mv "$TEMP_DIR/${VERSION}"/* "$DST_DIR/"
rm -rf "$TEMP_DIR"

echo "OpenCV documentation installed to $DST_DIR"

# Create Windows Start Menu shortcut
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    echo ""
    bash "$(dirname "$0")/../create-doc-shortcuts.sh" \
        --doc-dir "opencv-doc" \
        --shortcut-name "OpenCV-Doc" \
        --description "OpenCV Documentation"
fi
