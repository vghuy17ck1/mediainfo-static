#!/usr/bin/env bash

# autotools_build <project dir> [configure options...]
autotools_build() {
    local project_dir="$1"
    shift
    refresh_config_scripts "$project_dir"
    (
        cd "$project_dir"
        ./configure ${HOST:+--host="$HOST"} "$@"
        make -j"$JOBS"
    )
}

build_mediainfo() {
    local source_dir="$SOURCE_ROOT/mediainfo"
    local url="${MEDIAINFO_SOURCE_URL//\{version\}/$MEDIAINFO_VERSION}"
    local graphviz=no cli_libs=
    # Official Windows builds load Graphviz at runtime when its DLLs are present.
    if [[ "$TARGET_OS" == windows ]]; then
        graphviz=runtime
        cli_libs=-lshell32
    fi
    fetch "$url" - "$source_dir"
    if [[ "$TARGET_OS" == windows ]]; then
        # size_t is never unsigned long on 64-bit Windows, but the check in old ZenLib releases says it is.
        sed -i 's/size_t_is_long="yes"/size_t_is_long="no"/' "$source_dir/ZenLib/Project/GNU/Library/configure"
    fi

    autotools_build "$source_dir/ZenLib/Project/GNU/Library" --enable-static --disable-shared
    autotools_build "$source_dir/MediaInfoLib/Project/GNU/Library" --enable-static --disable-shared \
        --with-libcurl="$PREFIX" --with-graphviz="$graphviz"
    refresh_config_scripts "$source_dir/MediaInfo/Project/GNU/CLI"
    (
        cd "$source_dir/MediaInfo/Project/GNU/CLI"
        ./configure ${HOST:+--host="$HOST"} --enable-staticlibs LIBS="$cli_libs"
        # libtool only links executables fully static with -all-static.
        make -j"$JOBS" LDFLAGS="-all-static $LDFLAGS"
    )
    MEDIAINFO_BINARY="$source_dir/MediaInfo/Project/GNU/CLI/mediainfo$EXE_SUFFIX"
    [[ -f "$MEDIAINFO_BINARY" ]] || die "mediainfo binary was not produced"
}
