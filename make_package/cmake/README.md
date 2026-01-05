# CMake Documentation Package

This directory contains scripts to install CMake documentation as zzpkg packages.

## Scripts

- `install_cmake-doc-4.2.1.sh` - Install CMake 4.2.1 documentation

## Usage

### Option 1: Copy from local CMake installation (Recommended)

If you already have CMake installed locally:

```bash
cd make_package/cmake

# On Windows (adjust path to your CMake installation)
CMAKE_INSTALL_DIR="D:/soft/cmake/4.2.0" bash install_cmake-doc-4.2.1.sh

# On Linux/Mac
CMAKE_INSTALL_DIR="/usr/local/cmake-4.2.1" bash install_cmake-doc-4.2.1.sh
```

### Option 2: Download and extract from binary package

If you don't have CMake installed:

```bash
cd make_package/cmake
bash install_cmake-doc-4.2.1.sh
```

This will download the CMake binary package (~56MB) and extract only the documentation.

### Reinstall

```bash
ZZPKG_CLEAN_INSTALL=true bash install_cmake-doc-4.2.1.sh
```

## Installation Location

Documentation will be installed to:
- `$ZZPKG_ROOT/cmake-doc/<version>/`

Default `ZZPKG_ROOT` is `$HOME/.zzpkg`

## Source

- CMake documentation is bundled within CMake binary packages
- https://cmake.org/documentation/
- https://github.com/Kitware/CMake/releases

## Note

This documentation package is not directly used by C++ projects, but is managed as part of your development environment for convenient reference.
