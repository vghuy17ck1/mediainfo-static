#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$ROOT_DIR/util/common.sh"

target="${1:-}"
valid_target "$target" || die "usage: makeimage.sh <target> (targets: ${TARGETS[*]})"
need_cmd docker
load_versions

image="$(target_image "$target")"
docker build \
    --build-arg LLVM_MINGW_URL="$LLVM_MINGW_URL" \
    --build-arg LLVM_MINGW_SHA256="$LLVM_MINGW_SHA256" \
    -t "mediainfo-static-$image" \
    "$ROOT_DIR/images/$image"
