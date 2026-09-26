#!/usr/bin/env bash

build_zlib() {
    local source_dir="$SOURCE_ROOT/zlib"
    fetch "$ZLIB_URL" "$ZLIB_SHA256" "$source_dir"
    cmake_build "$source_dir" -DZLIB_BUILD_SHARED=OFF -DZLIB_BUILD_STATIC=ON -DZLIB_BUILD_TESTING=OFF
    # The static library is named libzs.a on Windows, but every consumer links with -lz.
    if [[ -f "$PREFIX/lib/libzs.a" && ! -f "$PREFIX/lib/libz.a" ]]; then
        cp "$PREFIX/lib/libzs.a" "$PREFIX/lib/libz.a"
    fi
    [[ -f "$PREFIX/lib/libz.a" ]] || die "zlib static library was not installed"
}
