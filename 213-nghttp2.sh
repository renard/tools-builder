#!/bin/bash
set -e
. "$(dirname $0)/env"
cd $SRC

if ! test -d nghttp2; then
    git clone --depth 1 -b $NGHTTP2_VERSION https://github.com/nghttp2/nghttp2 
fi

cd nghttp2
git submodule update --init --depth 1
autoreconf -i

./configure --enable-http3 --enable-app \
      --prefix=$PREFIX \
      PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig"

make -j$(nproc)
make install

