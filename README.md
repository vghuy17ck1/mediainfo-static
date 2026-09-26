# mediainfo-static

Single binary builds of the [MediaInfo](https://github.com/MediaArea/MediaInfo) CLI for Linux and Windows, on x86-64 and ARM64.

Downloads are on the [releases page](../../releases). Each archive holds one `mediainfo` executable and its license.

## Targets

| Target | Platform | Toolchain | Runtime |
| --- | --- | --- | --- |
| `linux64` | Linux x86-64 | Alpine GCC, musl | fully static, any distribution |
| `linuxarm64` | Linux ARM64 | Alpine GCC, musl | fully static, any distribution |
| `win64` | Windows x86-64 | llvm-mingw, UCRT | system DLLs only, Windows 10 or later |
| `winarm64` | Windows ARM64 | llvm-mingw, UCRT | system DLLs only, Windows 10 or later |

## Features

The builds match the official MediaInfo CLI releases:

- every parser and output format of the official source release
- URL input over HTTP, HTTPS, FTP and SFTP through libcurl and libssh2
- OpenSSL on Linux, reading the CA store from `/etc/ssl`, and Schannel on Windows
- on Windows, graph output loads Graphviz at runtime when it is installed

Library versions are pinned in `versions.env`.

## Layout

- `build.sh`: builds one target inside its image and packages it into `artifacts/`
- `run.sh`: builds the image for a target and runs `build.sh` in it
- `makeimage.sh`: builds the Docker image for a target
- `images/`: Alpine image for Linux targets, Ubuntu with llvm-mingw for Windows targets
- `targets/`: compiler and flags for each target
- `scripts.d/`: one script per library, run in order
- `tests/`: linkage check and smoke test
- `util/`: shared helpers, version resolution and release publishing

## Building

Builds run on GitHub Actions. Start the **Build** workflow manually:

- leave `version` empty to build the latest stable MediaInfo release, or set a tag such as `v24.12`
- untick `release` to build and test without publishing

Linux targets build natively on x86-64 and ARM64 runners. Windows targets are cross compiled on Linux and then run on Windows x86-64 and ARM64 runners before release.

To build locally with Docker:

```bash
./run.sh linux64 v26.05
```

## License

The build scripts are MIT licensed. MediaInfo is released under the BSD 2-Clause license, and the bundled libraries keep their own licenses.
