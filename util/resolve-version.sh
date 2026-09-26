#!/usr/bin/env bash
set -euo pipefail

# resolve-version.sh [version]
# Prints the MediaInfo release tag to build: the given version, or the latest stable tag.
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT_DIR/util/common.sh"
load_versions

requested="${1:-}"
if [[ -z "$requested" ]]; then
    requested="$(gh api --paginate "repos/$MEDIAINFO_REPO/tags" --jq '.[].name' \
        | grep -E '^v[0-9]+\.[0-9]+(\.[0-9]+)?$' | sort -V | tail -n 1)"
    [[ -n "$requested" ]] || die "no stable MediaInfo tag found"
fi
tag="v${requested#v}"
gh api "repos/$MEDIAINFO_REPO/git/ref/tags/$tag" >/dev/null 2>&1 || die "MediaInfo tag not found: $tag"
printf '%s\n' "$tag"
