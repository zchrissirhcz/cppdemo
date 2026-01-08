#!/bin/bash
set -euo pipefail

# === Main ===
VERSION="3.14"
FILENAME="python-${VERSION}-docs-html.zip"
URL="https://docs.python.org/3/archives/${FILENAME}"

# if not exist zip file, download it
if [[ ! -f "$FILENAME" ]]; then
    echo "Downloading Python ${VERSION} documentation..."
    curl -fSL -o "$FILENAME" "$URL"
fi

: "${ZZPKG_ROOT:=$HOME/.zzpkg}"
: "${ZZPKG_CLEAN_INSTALL:=false}"

DST_DIR="${ZZPKG_ROOT}/python-doc/${VERSION}"

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
                --doc-dir "python-doc" \
                --shortcut-name "Python-Doc" \
                --description "Python Documentation"
        fi
        exit 0
    fi
fi

TEMP_DIR="${ZZPKG_ROOT}/python-doc/.temp"
mkdir -p "$TEMP_DIR"
echo "Extracting to temporary directory..."
unzip -q "$FILENAME" -d "$TEMP_DIR"

# Move from temp to final destination
if [[ -d "$TEMP_DIR/python-${VERSION}-docs-html" ]]; then
    echo "Moving to $DST_DIR..."
    mv "$TEMP_DIR/python-${VERSION}-docs-html" "$DST_DIR"
else
    # If no subdirectory, move the whole temp dir
    mv "$TEMP_DIR" "$DST_DIR"
fi
rm -rf "$TEMP_DIR"

echo "Python documentation installed to $DST_DIR"
echo "You can open: $DST_DIR/index.html"

# Create Windows Start Menu shortcut if on Windows
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" || "$OSTYPE" == "cygwin" ]]; then
    echo ""
    bash "$(dirname "$0")/../create-doc-shortcuts.sh" \
        --doc-dir "python-doc" \
        --shortcut-name "Python-Doc" \
        --description "Python Documentation"
fi
