#!/bin/bash
set -e
. "$(dirname $0)/env"
cd $SRC


if ! test -d nghttp3; then
    git clone --depth 1 -b $NGHTTP3_VERSION https://github.com/ngtcp2/nghttp3
fi 
cd nghttp3
git submodule update --init --depth 1
autoreconf -i
./configure --prefix=$PREFIX --enable-lib-only
make -j$(nproc)
make install

