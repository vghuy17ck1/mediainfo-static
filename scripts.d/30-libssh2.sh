#!/usr/bin/env bash

build_libssh2() {
    local source_dir="$SOURCE_ROOT/libssh2"
    local crypto_backend=OpenSSL
    [[ "$TARGET_OS" == windows ]] && crypto_backend=WinCNG
    fetch "$LIBSSH2_URL" "$LIBSSH2_SHA256" "$source_dir"
    cmake_build "$source_dir" \
        -DCRYPTO_BACKEND="$crypto_backend" \
        -DENABLE_ZLIB_COMPRESSION=ON \
        -DBUILD_STATIC_LIBS=ON \
        -DBUILD_EXAMPLES=OFF \
        -DBUILD_TESTING=OFF
}
