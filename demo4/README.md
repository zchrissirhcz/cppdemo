cmake -S . -B build-linux && cmake --build build-linux --target install
readelf -d build-linux/install/lib/libfoo.so | grep -E 'RPATH|RUNPATH'