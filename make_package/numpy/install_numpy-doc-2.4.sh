#!/bin/bash
set -euo pipefail

# === Main ===
VERSION="2.4"
FILENAME="numpy-html.zip"
URL="https://numpy.org/doc/${VERSION}/${FILENAME}"

# if not exist zip file, download it
if [[ ! -f "$FILENAME" ]]; then
    echo "Downloading NumPy ${VERSION} documentation..."
    curl -fSL -o "$FILENAME" "$URL"
fi

: "${ZZPKG_ROOT:=$HOME/.zzpkg}"
: "${ZZPKG_CLEAN_INSTALL:=false}"

DST_DIR="${ZZPKG_ROOT}/numpy-doc/${VERSION}"

# Check if already installed
if [[ -d "$DST_DIR" && -f "$DST_DIR/index.html" ]]; then
    if [[ "$ZZPKG_CLEAN_INSTALL" == "true" ]]; then
        echo "Removing old installation..."
        rm -rf "$DST_DIR"
    else
        echo "Documentation already installed at $DST_DIR"
        echo "Skipping extraction. (Set ZZPKG_CLEAN_INSTALL=true to reinstall)"
        echo "You can open: $DST_DIR/index.html"
        
        # Still create shortcut
        if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" || "$OSTYPE" == "cygwin" ]]; then
            echo ""
            bash "$(dirname "$0")/../create-doc-shortcuts.sh" \
                --doc-dir "numpy-doc" \
                --shortcut-name "NumPy-Doc" \
                --description "NumPy Documentation"
        fi
        exit 0
    fi
fi

mkdir -p "$DST_DIR"
echo "Extracting to $DST_DIR..."
unzip -q "$FILENAME" -d "$DST_DIR"

echo "NumPy documentation installed to $DST_DIR"
echo "You can open: $DST_DIR/index.html"

# Create Windows Start Menu shortcut if on Windows
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" || "$OSTYPE" == "cygwin" ]]; then
    echo ""
    bash "$(dirname "$0")/../create-doc-shortcuts.sh" \
        --doc-dir "numpy-doc" \
        --shortcut-name "NumPy-Doc" \
        --description "NumPy Documentation"
fi
