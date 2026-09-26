#!/usr/bin/env bash
set -euo pipefail

# run.sh <target> <mediainfo version>
# Builds the target image, then runs build.sh inside it.
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$ROOT_DIR/util/common.sh"

target="${1:-}"
valid_target "$target" && [[ -n "${2:-}" ]] || die "usage: run.sh <target> <mediainfo version> (targets: ${TARGETS[*]})"
"$ROOT_DIR/makeimage.sh" "$target"
docker run --rm \
    --user "$(id -u):$(id -g)" \
    -e HOME=/tmp \
    -v "$ROOT_DIR:/build" \
    "mediainfo-static-$(target_image "$target")" \
    ./build.sh "$@"
