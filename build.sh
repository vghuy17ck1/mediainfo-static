#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$ROOT_DIR/util/common.sh"

target="${1:-}"
version="${2:-}"
valid_target "$target" && [[ -n "$version" ]] || die "usage: build.sh <target> <mediainfo version> (targets: ${TARGETS[*]})"

load_versions
export MEDIAINFO_VERSION="${version#v}"
source "$ROOT_DIR/targets/$target.sh"
target_setup

WORK_DIR="${WORK_DIR:-$ROOT_DIR/work/$target}"
export CACHE_DIR="${CACHE_DIR:-$ROOT_DIR/work/cache}"
export SOURCE_ROOT="$WORK_DIR/src" PREFIX="$WORK_DIR/prefix"
export JOBS="${JOBS:-$(nproc)}"
export EXE_SUFFIX=
[[ "$TARGET_OS" == windows ]] && EXE_SUFFIX=.exe
rm -rf "$WORK_DIR"
mkdir -p "$SOURCE_ROOT" "$PREFIX" "$ROOT_DIR/artifacts"

export CPPFLAGS="-I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"
export PKG_CONFIG_LIBDIR="$PREFIX/lib/pkgconfig" PKG_CONFIG_PATH=

for script in "$ROOT_DIR"/scripts.d/*.sh; do
    source "$script"
done

log "building zlib $ZLIB_VERSION"
build_zlib
log "building OpenSSL $OPENSSL_VERSION"
build_openssl
log "building libssh2 $LIBSSH2_VERSION"
build_libssh2
log "building curl $CURL_VERSION"
build_curl
log "building MediaInfo $MEDIAINFO_VERSION"
build_mediainfo

package_dir="$WORK_DIR/package"
mkdir -p "$package_dir"
"$STRIP" -o "$package_dir/mediainfo$EXE_SUFFIX" "$MEDIAINFO_BINARY"
cp "$SOURCE_ROOT/mediainfo/MediaInfo/LICENSE" "$package_dir/LICENSE"
bash "$ROOT_DIR/tests/verify-linkage.sh" "$target" "$package_dir/mediainfo$EXE_SUFFIX"
# Windows binaries are run by the workflow on Windows runners.
[[ "$TARGET_OS" == linux ]] && bash "$ROOT_DIR/tests/smoke-test.sh" "$package_dir/mediainfo"

archive_name="mediainfo-v$MEDIAINFO_VERSION-$target"
(
    cd "$package_dir"
    if [[ "$TARGET_OS" == windows ]]; then
        zip -q -9 "$ROOT_DIR/artifacts/$archive_name.zip" ./*
    else
        tar -cJf "$ROOT_DIR/artifacts/$archive_name.tar.xz" --owner=0 --group=0 ./*
    fi
)
log "packaged artifacts/$archive_name"
