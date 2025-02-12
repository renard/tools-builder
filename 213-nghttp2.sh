#!/bin/bash
set -e
. "$(dirname $0)/env"
cd $SRC

if ! test -d nghttp2; then
    git clone https://github.com/nghttp2/nghttp2 
fi

cd nghttp2
git submodule update --init --depth 1
autoreconf -i

./configure --enable-http3 --enable-app \
      --prefix=$PREFIX \
      PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig" \
      LDFLAGS="$LDFLAGS -Wl,-rpath,$PREFIX/lib"
      

make -j$(nproc)
make install

