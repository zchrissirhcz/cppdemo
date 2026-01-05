#!/bin/bash
set -euo pipefail

# === Main ===
VERSION="4.2.1"
: "${ZZPKG_ROOT:=$HOME/.zzpkg}"
: "${ZZPKG_CLEAN_INSTALL:=false}"
: "${CMAKE_INSTALL_DIR:=}"

DST_DIR="${ZZPKG_ROOT}/cmake-doc/${VERSION}"

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
                --doc-dir "cmake-doc" \
                --shortcut-name "CMake-Doc" \
                --description "CMake Documentation"
        fi
        exit 0
    fi
fi

# Option 1: Copy from local CMake installation if CMAKE_INSTALL_DIR is provided
if [[ -n "$CMAKE_INSTALL_DIR" ]]; then
    CMAKE_DOC_DIR="$CMAKE_INSTALL_DIR/doc/cmake/html"
    if [[ -d "$CMAKE_DOC_DIR" && -f "$CMAKE_DOC_DIR/index.html" ]]; then
        echo "Copying documentation from local CMake installation..."
        echo "Source: $CMAKE_DOC_DIR"
        mkdir -p "$DST_DIR"
        cp -r "$CMAKE_DOC_DIR"/* "$DST_DIR/"
        echo "CMake documentation installed to $DST_DIR"
        echo "You can open: $DST_DIR/index.html"
        
        # Create Windows Start Menu shortcut if on Windows
        if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" || "$OSTYPE" == "cygwin" ]]; then
            echo ""
            bash "$(dirname "$0")/../create-doc-shortcuts.sh" \
                --doc-dir "cmake-doc" \
                --shortcut-name "CMake-Doc" \
                --description "CMake Documentation"
        fi
        exit 0
    else
        echo "Error: Documentation not found at $CMAKE_DOC_DIR"
        echo "Please check CMAKE_INSTALL_DIR path"
        exit 1
    fi
fi

# Option 2: Download and extract from binary package
FILENAME="cmake-${VERSION}-linux-x86_64.tar.gz"
URL="https://github.com/Kitware/CMake/releases/download/v${VERSION}/${FILENAME}"

echo "No local CMake installation provided."
echo "Will download CMake binary package and extract documentation."
echo ""

# Download if not exist
if [[ ! -f "$FILENAME" ]]; then
    echo "Downloading CMake ${VERSION} binary package..."
    curl -fSL -o "$FILENAME" "$URL"
fi

mkdir -p "$DST_DIR"
echo "Extracting documentation to $DST_DIR..."
# Extract only the doc/cmake/html directory from the tarball
tar -xzf "$FILENAME" --strip-components=4 -C "$DST_DIR" "cmake-${VERSION}-linux-x86_64/doc/cmake/html"

echo "CMake documentation installed to $DST_DIR"
echo "You can open: $DST_DIR/index.html"

# Create Windows Start Menu shortcut if on Windows
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" || "$OSTYPE" == "cygwin" ]]; then
    echo ""
    bash "$(dirname "$0")/../create-doc-shortcuts.sh" \
        --doc-dir "cmake-doc" \
        --shortcut-name "CMake-Doc" \
        --description "CMake Documentation"
fi
