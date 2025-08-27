#!/bin/bash
set -e
. "$(dirname $0)/env"
cd $SRC

if ! test -d curl; then
    git clone --depth 1 -b  $CURL_VERSION https://github.com/curl/curl
fi

cd curl

autoreconf -fi
./configure \
    PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig" \
    --with-openssl="$PREFIX" \
    --with-nghttp3="$PREFIX" \
    --with-ngtcp2="$PREFIX" \
    --prefix="$PREFIX"

make -j$(nproc)
make install-strip
