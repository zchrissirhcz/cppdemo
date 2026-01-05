# Documentation Shortcuts

## Overview

This directory contains a unified shortcut creation system for all documentation packages.

## Universal Scripts

### `create-doc-shortcuts.sh` / `create-doc-shortcuts.ps1`

Universal scripts that create Windows Start Menu shortcuts for any documentation.

**Usage:**
```bash
bash create-doc-shortcuts.sh \
    --doc-dir <directory-name> \
    --shortcut-name <shortcut-name> \
    --description <description>
```

**Parameters:**
- `--doc-dir`: Documentation directory name under `$ZZPKG_ROOT` (e.g., `cppreference-doc-en`)
- `--shortcut-name`: Name of the shortcut file (e.g., `CppReference`)
- `--description`: Description shown in shortcut properties (optional)
- `--zzpkg-root`: Override default ZZPKG_ROOT (optional)
- `--start-menu-folder`: Start Menu folder name (default: `cppdoc`)

**Examples:**
```bash
# C++ Reference (English)
bash create-doc-shortcuts.sh \
    --doc-dir "cppreference-doc-en" \
    --shortcut-name "CppReference" \
    --description "C++ Reference"

# OpenCV Documentation
bash create-doc-shortcuts.sh \
    --doc-dir "opencv-doc" \
    --shortcut-name "OpenCV-Doc" \
    --description "OpenCV Documentation"
```

### `create-all-shortcuts.sh`

Batch script that creates shortcuts for all installed documentation at once.

**Usage:**
```bash
bash create-all-shortcuts.sh
```

This will scan for and create shortcuts for:
- CppReference (English & Chinese)
- Python Documentation
- NumPy Documentation
- CMake Documentation  
- Eigen Documentation
- OpenCV Documentation

## Integration with Installation Scripts

Each documentation installation script (`install_*-doc-*.sh`) automatically calls the universal shortcut creation script:

```bash
# In install script:
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    bash "$(dirname "$0")/../create-doc-shortcuts.sh" \
        --doc-dir "opencv-doc" \
        --shortcut-name "OpenCV-Doc" \
        --description "OpenCV Documentation"
fi
```

## Features

✅ **Auto-version detection**: Automatically finds the latest installed version  
✅ **Unified interface**: Single script for all documentation types  
✅ **Key-value parameters**: Clear and explicit parameter names  
✅ **Batch processing**: Create all shortcuts at once with one command  
✅ **No code duplication**: Eliminates redundant per-doc shortcut scripts

## Directory Structure

```
make_package/
├── create-doc-shortcuts.sh       # Universal bash wrapper
├── create-doc-shortcuts.ps1      # Universal PowerShell script
├── create-all-shortcuts.sh       # Batch shortcut creator
├── cppreference/
│   └── install_cppreference-doc-*.sh
├── python/
│   └── install_python-doc-*.sh
├── numpy/
│   └── install_numpy-doc-*.sh
├── cmake/
│   └── install_cmake-doc-*.sh
├── eigen/
│   └── install_eigen-doc-*.sh
└── opencv/
    └── install-opencv-doc.sh
```

## Migration Notes

Old individual `create-windows-shortcuts.{sh,ps1}` files in each subdirectory can be removed as they are replaced by the universal scripts.

The universal scripts provide the same functionality with:
- Less code duplication
- Easier maintenance
- More flexible configuration
- Better parameter clarity
