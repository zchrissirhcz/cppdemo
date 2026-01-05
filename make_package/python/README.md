# Python Documentation Package

This directory contains scripts to install Python documentation as zzpkg packages.

## Scripts

- `install_python-doc-3.14.sh` - Install Python 3.14 documentation

## Usage

```bash
cd make_package/python
bash install_python-doc-3.14.sh
```

## Installation Location

Documentation will be installed to:
- `$ZZPKG_ROOT/python-doc/<version>/`

Default `ZZPKG_ROOT` is `$HOME/.zzpkg`

## Source

- https://docs.python.org/3/download.html

## Note

This documentation package is not directly used by C++ projects, but is managed as part of your development environment for convenient reference.
