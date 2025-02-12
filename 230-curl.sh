#!/bin/bash
set -e
. "$(dirname $0)/env"
cd $SRC

if ! test -d curl; then
    git clone https://github.com/curl/curl
fi

cd curl
git checkout $CURL_VERSION
autoreconf -fi
./configure \
    PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig" \
    LDFLAGS="-Wl,-rpath=$PREFIX/lib" \
    --with-openssl="$PREFIX" \
    --with-nghttp3="$PREFIX" \
    --with-ngtcp2="$PREFIX" \
    --prefix="$PREFIX"

make -j$(nproc)
make install-strip
