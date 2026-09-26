#!/usr/bin/env bash

# Linux only: Windows builds use Schannel from the operating system.
build_openssl() {
    [[ "$TARGET_OS" == linux ]] || return 0
    local source_dir="$SOURCE_ROOT/openssl"
    fetch "$OPENSSL_URL" "$OPENSSL_SHA256" "$source_dir"
    (
        cd "$source_dir"
        # /etc/ssl holds the CA store on most distributions, so certificate checks work out of the box.
        ./Configure "$OPENSSL_TARGET" no-shared no-tests no-docs no-apps no-module \
            --prefix="$PREFIX" --libdir=lib --openssldir=/etc/ssl
        make -j"$JOBS" build_libs
        make install_dev
    )
}
