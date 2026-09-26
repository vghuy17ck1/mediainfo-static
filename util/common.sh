#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export ROOT_DIR

TARGETS=(linux64 linuxarm64 win64 winarm64)

die() {
    printf 'error: %s\n' "$*" >&2
    exit 1
}

log() {
    printf '==> %s\n' "$*" >&2
}

need_cmd() {
    command -v "$1" >/dev/null 2>&1 || die "required command not found: $1"
}

valid_target() {
    local target
    for target in "${TARGETS[@]}"; do
        [[ "$1" == "$target" ]] && return 0
    done
    return 1
}

target_image() {
    case "$1" in
        linux64|linuxarm64) printf 'linux\n' ;;
        win64|winarm64) printf 'windows\n' ;;
        *) die "unknown target: $1" ;;
    esac
}

load_versions() {
    set -a
    source "$ROOT_DIR/versions.env"
    set +a
}

# fetch <url> <sha256|-> <destination directory>
# Downloads a source archive once into the cache and extracts it without its top-level directory.
fetch() {
    local url="$1" sha256="$2" dest="$3"
    local archive="$CACHE_DIR/${url##*/}"
    mkdir -p "$CACHE_DIR"
    if [[ ! -f "$archive" ]]; then
        log "downloading ${url##*/}"
        curl --fail --silent --show-error --location --retry 5 --retry-delay 3 -o "$archive.part" "$url"
        mv "$archive.part" "$archive"
    fi
    if [[ "$sha256" != - ]]; then
        printf '%s  %s\n' "$sha256" "$archive" | sha256sum -c - >/dev/null || die "checksum mismatch: ${url##*/}"
    fi
    rm -rf "$dest"
    mkdir -p "$dest"
    tar -xf "$archive" -C "$dest" --strip-components=1
}

# cmake_build <source dir> [cmake options...]
cmake_build() {
    local source_dir="$1"
    shift
    local system_name=Linux
    [[ "$TARGET_OS" == windows ]] && system_name=Windows
    cmake -S "$source_dir" -B "$source_dir/build" -G Ninja \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$PREFIX" \
        -DCMAKE_INSTALL_LIBDIR=lib \
        -DCMAKE_PREFIX_PATH="$PREFIX" \
        -DCMAKE_FIND_ROOT_PATH="$PREFIX" \
        -DCMAKE_SYSTEM_NAME="$system_name" \
        -DCMAKE_SYSTEM_PROCESSOR="$TARGET_ARCH" \
        -DCMAKE_C_COMPILER="$CC" \
        -DCMAKE_CXX_COMPILER="$CXX" \
        -DCMAKE_AR="$(command -v "$AR")" \
        -DCMAKE_RANLIB="$(command -v "$RANLIB")" \
        -DCMAKE_RC_COMPILER="${WINDRES:-}" \
        -DBUILD_SHARED_LIBS=OFF \
        "$@"
    cmake --build "$source_dir/build" --parallel "$JOBS"
    cmake --install "$source_dir/build"
}

# Replaces bundled autotools helpers so old source releases recognise current host triplets.
refresh_config_scripts() {
    local dir="$1" automake_dir
    automake_dir="$(automake --print-libdir)"
    cp "$automake_dir/config.sub" "$automake_dir/config.guess" "$dir/"
}
