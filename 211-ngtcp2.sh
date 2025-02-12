#!/bin/bash
set -e
. "$(dirname $0)/env"
cd $SRC

if ! test -d ngtcp2; then
    git clone --depth 1 -b $NGTCP3_VERSION https://github.com/ngtcp2/ngtcp2
fi

cd ngtcp2
git submodule update --init --depth 1
autoreconf -i

./configure --prefix=$PREFIX --enable-lib-only --with-boringssl \
      BORINGSSL_CFLAGS="-I$PREFIX/include" \
      BORINGSSL_LIBS="-L$PREFIX/lib -lssl -lcrypto"


make -j$(nproc)
make install

