#!/usr/bin/env bash
set -euo pipefail

# smoke-test.sh <binary>
# Runs the binary against a local sample and the same sample over HTTPS.
binary="$1"
sample_url=https://raw.githubusercontent.com/MediaArea/MediaInfo/master/Release/Example.ogg
sample="$(mktemp -d)/Example.ogg"

check_output() {
    local label="$1" output="$2"
    grep -q 'Vorbis' <<<"$output" || {
        printf '%s\n' "$output" >&2
        printf 'smoke test failed: %s\n' "$label" >&2
        exit 1
    }
    printf 'smoke test passed: %s\n' "$label"
}

"$binary" --Version
curl --fail --silent --show-error --location --retry 5 -o "$sample" "$sample_url"
check_output "local file" "$("$binary" "$sample" | tr -d '\r')"
check_output "https input" "$("$binary" "$sample_url" | tr -d '\r')"
