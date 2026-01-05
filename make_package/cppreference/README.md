# Cppreference Documentation Package

This directory contains scripts to install cppreference documentation as zzpkg packages.

## Scripts

- `install_cppreference-doc-en.sh` - Install English cppreference documentation
- `install_cppreference-doc-zh.sh` - Install Chinese cppreference documentation
- `create-windows-shortcuts.sh` - Create Windows Start Menu shortcuts (called automatically)
- `create-windows-shortcuts.ps1` - PowerShell script for creating shortcuts

## Usage

```bash
cd make_package/cppreference

# Install English version
bash install_cppreference-doc-en.sh

# Install Chinese version
bash install_cppreference-doc-zh.sh

# Reinstall (clean install)
ZZPKG_CLEAN_INSTALL=true bash install_cppreference-doc-en.sh

# Or manually create shortcuts (if needed)
bash create-windows-shortcuts.sh
```

On Windows, the installation scripts will automatically create Start Menu shortcuts, so you can:
1. Press Win key and search for "cppreference" or "cpp" 
2. Click the shortcut to open the documentation in your browser

### Options

- `ZZPKG_ROOT` - Installation root directory (default: `$HOME/.zzpkg`)
- `ZZPKG_CLEAN_INSTALL` - Set to `true` to remove and reinstall existing documentation (default: `false`)

## Installation Location

Documentation will be installed to:
- English: `$ZZPKG_ROOT/cppreference-doc-en/<version>/`
- Chinese: `$ZZPKG_ROOT/cppreference-doc-zh/<version>/`

Default `ZZPKG_ROOT` is `$HOME/.zzpkg`

## Sources

- English: https://github.com/PeterFeicht/cppreference-doc
- Chinese: https://zh.cppreference.com/ or community mirrors

## Note

These documentation packages are not directly used by C++ projects, but are managed as part of your development environment for convenient reference.
