#!/usr/bin/env bash
set -euo pipefail

# publish-release.sh <tag> <artifact dir>
# Creates the GitHub release for a MediaInfo tag, or replaces the assets of an existing one.
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT_DIR/util/common.sh"

tag="$1"
artifact_dir="$2"
notes="$(mktemp)"

(cd "$artifact_dir" && sha256sum -- *.tar.xz *.zip > checksums.sha256)
bash "$ROOT_DIR/util/release-notes.sh" "$tag" > "$notes"

# Only the highest version becomes the latest release, so older versions can be built at any time.
newest="$( (gh release list --limit 1000 --json tagName --jq '.[].tagName'; printf '%s\n' "$tag") | sort -V | tail -n 1)"
latest=false
[[ "$newest" == "$tag" ]] && latest=true

if gh release view "$tag" >/dev/null 2>&1; then
    gh release edit "$tag" --title "MediaInfo $tag" --notes-file "$notes" --latest="$latest"
    gh release upload "$tag" "$artifact_dir"/* --clobber
else
    gh release create "$tag" "$artifact_dir"/* --target "$GITHUB_SHA" --title "MediaInfo $tag" --notes-file "$notes" --latest="$latest"
fi
