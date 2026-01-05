#!/bin/bash
# Universal script to create Windows Start Menu shortcuts for documentation
# Usage: create-doc-shortcuts.sh --doc-dir cppreference-doc-en --shortcut-name CppReference --description "C++ Reference"

set -euo pipefail

# Default values
DOC_DIR=""
SHORTCUT_NAME=""
DESCRIPTION=""
ZZPKG_ROOT="${ZZPKG_ROOT:-$HOME/.zzpkg}"
START_MENU_FOLDER="cppdoc"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --doc-dir)
            DOC_DIR="$2"
            shift 2
            ;;
        --shortcut-name)
            SHORTCUT_NAME="$2"
            shift 2
            ;;
        --description)
            DESCRIPTION="$2"
            shift 2
            ;;
        --zzpkg-root)
            ZZPKG_ROOT="$2"
            shift 2
            ;;
        --start-menu-folder)
            START_MENU_FOLDER="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 --doc-dir <dir> --shortcut-name <name> [--description <desc>] [--zzpkg-root <path>]"
            exit 1
            ;;
    esac
done

# Validate required parameters
if [[ -z "$DOC_DIR" || -z "$SHORTCUT_NAME" ]]; then
    echo "Error: --doc-dir and --shortcut-name are required"
    echo "Usage: $0 --doc-dir <dir> --shortcut-name <name> [--description <desc>]"
    exit 1
fi

# Only create shortcuts on Windows
if [[ "$OSTYPE" != "msys" && "$OSTYPE" != "win32" ]]; then
    echo "Skipping shortcut creation (not on Windows)"
    exit 0
fi

# Convert bash path to Windows path format
WINDOWS_PATH=$(cygpath -w "$ZZPKG_ROOT" 2>/dev/null || echo "$ZZPKG_ROOT" | sed 's|^/\([a-z]\)/|\1:/|')

# Call PowerShell script
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
powershell.exe -ExecutionPolicy Bypass -File "$SCRIPT_DIR/create-doc-shortcuts.ps1" \
    -DocDir "$DOC_DIR" \
    -ShortcutName "$SHORTCUT_NAME" \
    -Description "$DESCRIPTION" \
    -ZzpkgRoot "$WINDOWS_PATH" \
    -StartMenuFolder "$START_MENU_FOLDER"
