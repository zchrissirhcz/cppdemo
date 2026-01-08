#!/bin/bash
set -euo pipefail

# === Main ===
VERSION="20250209"
FILENAME="html-book-${VERSION}.zip"
URL="https://github.com/PeterFeicht/cppreference-doc/releases/download/v${VERSION}/${FILENAME}"

# if not exist zip file, download it
if [[ ! -f "$FILENAME" ]]; then
    echo "Downloading cppreference ${VERSION} documentation (English)..."
    curl -fSL -o "$FILENAME" "$URL"
fi

: "${ZZPKG_ROOT:=$HOME/.zzpkg}"
: "${ZZPKG_CLEAN_INSTALL:=false}"

DST_DIR="${ZZPKG_ROOT}/cppreference-doc-en/${VERSION}"

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
                --doc-dir "cppreference-doc-en" \
                --shortcut-name "CppReference" \
                --description "C++ Reference"
        fi
        exit 0
    fi
fi

mkdir -p "$DST_DIR"
echo "Extracting to $DST_DIR..."
unzip -q "$FILENAME" -d "$DST_DIR"

echo "Cppreference documentation (English) installed to $DST_DIR"
echo "You can open: $DST_DIR/index.html"

# Create Windows Start Menu shortcut if on Windows
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" || "$OSTYPE" == "cygwin" ]]; then
    echo ""
    bash "$(dirname "$0")/../create-doc-shortcuts.sh" \
        --doc-dir "cppreference-doc-en" \
        --shortcut-name "CppReference" \
        --description "C++ Reference"
fi
