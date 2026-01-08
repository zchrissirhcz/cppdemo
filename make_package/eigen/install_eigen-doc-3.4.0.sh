#!/bin/bash
set -euo pipefail

# === Main ===
VERSION="3.4"
FILENAME="eigen-doc.tgz"
URL="https://libeigen.gitlab.io/eigen/docs-${VERSION}/${FILENAME}"

: "${ZZPKG_ROOT:=$HOME/.zzpkg}"
: "${ZZPKG_CLEAN_INSTALL:=false}"

DST_DIR="${ZZPKG_ROOT}/eigen-doc/${VERSION}"

# Check if already installed
if [[ -d "$DST_DIR" && -f "$DST_DIR/index.html" ]]; then
    if [[ "$ZZPKG_CLEAN_INSTALL" == "true" ]]; then
        echo "Removing existing installation..."
        rm -rf "$DST_DIR"
    else
        echo "Eigen ${VERSION} already installed. Skipping download and extraction."
        echo "Set ZZPKG_CLEAN_INSTALL=true to reinstall."
        
        # Still create shortcut on Windows
        if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
            echo ""
            bash "$(dirname "$0")/../create-doc-shortcuts.sh" \
                --doc-dir "eigen-doc" \
                --shortcut-name "Eigen-Doc" \
                --description "Eigen Documentation"
        fi
        
        echo "Documentation location: $DST_DIR"
        exit 0
fi

# if not exist eigen-doc.tgz, download it
if [[ ! -f "$FILENAME" ]]; then
    echo "Downloading Eigen ${VERSION} documentation..."
    curl -fSL -o "$FILENAME" "$URL"
fi

mkdir -p "$DST_DIR"
echo "Extracting to $DST_DIR..."
tar -xzf "$FILENAME" -C "$DST_DIR" --strip-components=1

echo "Eigen documentation installed to $DST_DIR"

# Create Windows Start Menu shortcut
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    echo ""
    bash "$(dirname "$0")/../create-doc-shortcuts.sh" \
        --doc-dir "eigen-doc" \
        --shortcut-name "Eigen-Doc" \
        --description "Eigen Documentation"
fi
