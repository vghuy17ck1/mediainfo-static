#!/usr/bin/env bash

target_setup() {
    export TARGET_OS=windows TARGET_ARCH=aarch64
    export HOST=aarch64-w64-mingw32
    export CC=$HOST-clang CXX=$HOST-clang++ AR=llvm-ar RANLIB=llvm-ranlib STRIP=llvm-strip WINDRES=$HOST-windres
    export CFLAGS="-O2 -ffunction-sections -fdata-sections"
    export CXXFLAGS="$CFLAGS"
    export LDFLAGS="-static -Wl,--gc-sections"
}
