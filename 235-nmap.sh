#!/bin/bash


set -e
. "$(dirname $0)/env"
cd $SRC

if ! test -d nmap; then
    git clone --depth 1 -b $NMAP_VERSION https://github.com/nmap/nmap 
fi
cd nmap
# nmap is not compatible with aws-lc
./configure \
    PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig" \
    CFLAGS="-I$PREFIX/include -L$PREFIX/lib" \
    --without-openssl \
    --prefix="$PREFIX"

make -j$(nproc)
make install
