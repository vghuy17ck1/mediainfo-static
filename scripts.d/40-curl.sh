#!/usr/bin/env bash

build_curl() {
    local source_dir="$SOURCE_ROOT/curl"
    local tls_options=(--with-openssl="$PREFIX" --with-ca-bundle=/etc/ssl/certs/ca-certificates.crt --with-ca-fallback)
    [[ "$TARGET_OS" == windows ]] && tls_options=(--with-schannel)
    fetch "$CURL_URL" "$CURL_SHA256" "$source_dir"
    (
        cd "$source_dir"
        ./configure ${HOST:+--host="$HOST"} --prefix="$PREFIX" \
            --disable-shared --enable-static \
            "${tls_options[@]}" \
            --with-zlib="$PREFIX" \
            --with-libssh2="$PREFIX" \
            --without-libpsl --without-brotli --without-zstd --without-nghttp2 \
            --without-libidn2 --without-librtmp --disable-ldap --disable-ldaps \
            --disable-docs --disable-manual
        make -j"$JOBS" -C lib
        make -C lib install
        make -C include install
        make install-pkgconfigDATA
    )
    grep -q libssh2 "$PREFIX/lib/pkgconfig/libcurl.pc" || die "libcurl was built without libssh2"
}
