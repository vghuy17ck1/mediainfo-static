#!/usr/bin/env bash
set -euo pipefail

# release-notes.sh <tag>
# Prints the release description in Markdown.
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT_DIR/util/common.sh"
load_versions

tag="$1"
version="${tag#v}"

cat <<EOF
MediaInfo CLI $tag built as a single binary for Linux and Windows. Nothing else to install, just extract and run.

## Downloads

| Platform | Architecture | File |
| --- | --- | --- |
| Linux | x86-64 | \`mediainfo-$tag-linux64.tar.xz\` |
| Linux | ARM64 | \`mediainfo-$tag-linuxarm64.tar.xz\` |
| Windows | x86-64 | \`mediainfo-$tag-win64.zip\` |
| Windows | ARM64 | \`mediainfo-$tag-winarm64.zip\` |

Checksums are in \`checksums.sha256\`.

## Build

- Built from the official MediaInfo $version source release.
- Same features as the official CLI builds, including URL input over HTTP, HTTPS, FTP and SFTP.
- Linux binaries are statically linked with musl and run on any distribution.
- Windows binaries only use system DLLs and need Windows 10 or later. Graph output loads Graphviz at runtime when it is installed, like the official build.

## Libraries

- zlib $ZLIB_VERSION
- libcurl $CURL_VERSION (OpenSSL $OPENSSL_VERSION on Linux, Schannel on Windows)
- libssh2 $LIBSSH2_VERSION

Upstream changes: https://github.com/$MEDIAINFO_REPO/blob/$tag/History_CLI.txt
EOF
