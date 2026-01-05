# NumPy Documentation Package

This directory contains scripts to install NumPy documentation as zzpkg packages.

## Scripts

- `install_numpy-doc-2.3.sh` - Install NumPy 2.3 documentation

## Usage

```bash
cd make_package/numpy
bash install_numpy-doc-2.3.sh
```

## Installation Location

Documentation will be installed to:
- `$ZZPKG_ROOT/numpy-doc/<version>/`

Default `ZZPKG_ROOT` is `$HOME/.zzpkg`

## Source

- https://numpy.org/doc/

## Note

This documentation package is not directly used by C++ projects, but is managed as part of your development environment for convenient reference.
