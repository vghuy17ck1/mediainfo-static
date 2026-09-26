#!/usr/bin/env bash
set -euo pipefail

# verify-linkage.sh <target> <binary>
# Fails when the binary depends on anything outside the operating system.
target="$1"
binary="$2"

fail() {
    printf 'linkage check failed: %s\n' "$*" >&2
    exit 1
}

case "$target" in
    linux64|linuxarm64)
        headers="$(readelf -lW "$binary")"
        dynamic="$(readelf -dW "$binary")"
        grep -q 'Requesting program interpreter' <<<"$headers" && fail "ELF interpreter present"
        grep -q '(NEEDED)' <<<"$dynamic" && fail "shared library dependencies: $(grep '(NEEDED)' <<<"$dynamic")"
        ;;
    win64|winarm64)
        system_dlls='^(api-ms-win-[a-z0-9-]+|kernel32|user32|advapi32|shell32|ws2_32|crypt32|bcrypt|secur32|iphlpapi)\.dll$'
        while read -r dll; do
            grep -Eiq "$system_dlls" <<<"$dll" || fail "non-system DLL import: $dll"
        done < <(llvm-objdump -p "$binary" | awk '/DLL Name:/ {print $3}')
        ;;
    *)
        fail "unknown target: $target"
        ;;
esac
printf 'linkage check passed: %s\n' "$binary"
