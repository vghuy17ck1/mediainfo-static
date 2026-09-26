#!/usr/bin/env bash

target_setup() {
    export TARGET_OS=linux TARGET_ARCH=aarch64
    export OPENSSL_TARGET=linux-aarch64
    [[ "$(uname -m)" == "$TARGET_ARCH" ]] || die "linuxarm64 must be built on a $TARGET_ARCH host"
    export CC=gcc CXX=g++ AR=ar RANLIB=ranlib STRIP=strip
    export CFLAGS="-O2 -fPIC -ffunction-sections -fdata-sections"
    export CXXFLAGS="$CFLAGS"
    export LDFLAGS="-static -Wl,--gc-sections"
}
