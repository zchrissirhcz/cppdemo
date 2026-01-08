#!/bin/bash
set -euo pipefail

# === Main ===
VERSION="20250404"
REPO_URL="https://github.com/HengXin666/cppreference-zh-cn.git"
ZIP_URL="https://github.com/HengXin666/cppreference-zh-cn/archive/refs/heads/main.zip"
FILENAME="cppreference-zh-cn.zip"

# if not exist zip file, download it
if [[ ! -f "$FILENAME" ]]; then
    echo "Downloading cppreference Chinese documentation (${VERSION})..."
    curl -fSL -o "$FILENAME" "$ZIP_URL"
fi

: "${ZZPKG_ROOT:=$HOME/.zzpkg}"
: "${ZZPKG_CLEAN_INSTALL:=false}"

DST_DIR="${ZZPKG_ROOT}/cppreference-doc-zh/${VERSION}"

# Check if already installed
if [[ -d "$DST_DIR" && -f "$DST_DIR/zh/index.html" ]]; then
    if [[ "$ZZPKG_CLEAN_INSTALL" == "true" ]]; then
        echo "Removing old installation..."
        rm -rf "$DST_DIR"
    else
        echo "Documentation already installed at $DST_DIR"
        echo "Skipping extraction. (Set ZZPKG_CLEAN_INSTALL=true to reinstall)"
        echo "You can open: $DST_DIR/zh/index.html"
        
        # Still create shortcut
        if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" || "$OSTYPE" == "cygwin" ]]; then
            echo ""
            bash "$(dirname "$0")/../create-doc-shortcuts.sh" \
                --doc-dir "cppreference-doc-zh" \
                --shortcut-name "CppReference-CN" \
                --description "C++ 参考手册"
        fi
        exit 0
    fi
fi

TEMP_DIR="${ZZPKG_ROOT}/cppreference-doc-zh/.temp"
mkdir -p "$TEMP_DIR"
echo "Extracting to temporary directory..."
unzip -q "$FILENAME" -d "$TEMP_DIR"

# Move from temp to final destination
echo "Moving to $DST_DIR..."
mv "$TEMP_DIR/cppreference-zh-cn-main" "$DST_DIR"
rm -rf "$TEMP_DIR"

echo "Cppreference documentation (Chinese) installed to $DST_DIR"
echo "You can open: $DST_DIR/zh/index.html"

# Create Windows Start Menu shortcut if on Windows
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" || "$OSTYPE" == "cygwin" ]]; then
    echo ""
    bash "$(dirname "$0")/../create-doc-shortcuts.sh" \
        --doc-dir "cppreference-doc-zh" \
        --shortcut-name "CppReference-CN" \
        --description "C++ 参考手册"
fi
