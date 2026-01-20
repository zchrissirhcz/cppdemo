#!/bin/bash

source checkout_pystring_1.1.4.sh

set -x

# replace CMakeLists.txt
cp CMakeLists.txt pystring/CMakeLists.txt

# put cmake/pystringConfig.cmake.in
mkdir -p pystring/cmake
cp pystringConfig.cmake.in pystring/cmake/


build_dir="$work_dir/build-vs2022-x64-static"

# Clean build
# [ -d "$build_dir" ] && rm -rf "$build_dir"

#CMAKE_GENERATOR_OPTIONS=-G"Visual Studio 16 2019"
#CMAKE_GENERATOR_OPTIONS=-G"Visual Studio 15 2017 Win64"
#CMAKE_GENERATOR_OPTIONS=(-G"Visual Studio 16 2019" -A x64)
CMAKE_GENERATOR_OPTIONS=(-G"Visual Studio 17 2022" -A x64)
#CMAKE_GENERATOR_OPTIONS=(-G"Visual Studio 18 2026" -A x64)

CMAKE_OPTIONS=(
  -DBUILD_SHARED_LIBS=OFF
  -DCMAKE_POLICY_VERSION_MINIMUM=3.5
  -DCMAKE_DEBUG_POSTFIX="_d"
)

: "${ZZPKG_ROOT:=$HOME/.zzpkg}"
install_dir="$ZZPKG_ROOT/${pkg_name}/$version/vs2022-x64-static"
cmake "${CMAKE_GENERATOR_OPTIONS[@]}" "${CMAKE_OPTIONS[@]}" \
      -DCMAKE_INSTALL_PREFIX="$install_dir" \
      -S "$source_dir" -B "$build_dir" -Wno-deprecated

cmake --build "$build_dir" --config Debug
cmake --build "$build_dir" --target install --config Debug
cmake --build "$build_dir" --config Release
cmake --build "$build_dir" --target install --config Release

