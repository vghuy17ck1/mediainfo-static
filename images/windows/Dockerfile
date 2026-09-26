FROM ubuntu:24.04
ARG DEBIAN_FRONTEND=noninteractive
ARG LLVM_MINGW_URL
ARG LLVM_MINGW_SHA256
RUN apt-get update && apt-get install -y --no-install-recommends \
        autoconf automake ca-certificates cmake curl file libtool make ninja-build \
        perl pkg-config xz-utils zip \
    && rm -rf /var/lib/apt/lists/*
RUN curl --fail --silent --show-error --location --retry 5 -o /tmp/llvm-mingw.tar.xz "$LLVM_MINGW_URL" \
    && echo "$LLVM_MINGW_SHA256  /tmp/llvm-mingw.tar.xz" | sha256sum -c - \
    && mkdir -p /opt/llvm-mingw \
    && tar -xJf /tmp/llvm-mingw.tar.xz -C /opt/llvm-mingw --strip-components=1 \
    && rm /tmp/llvm-mingw.tar.xz
ENV PATH=/opt/llvm-mingw/bin:$PATH
WORKDIR /build
