#!/bin/bash

cmake -S . -B build-android -G Ninja \
      -DCMAKE_TOOLCHAIN_FILE="/C/soft/android-ndk/r27c/build/cmake/android.toolchain.cmake" \
      -DANDROID_ABI="arm64-v8a" \
      -DANDROID_PLATFORM=android-21 \
      -DCMAKE_BUILD_TYPE=Release \
      -Wno-deprecated