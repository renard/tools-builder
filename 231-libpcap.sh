#!/bin/bash
set -e
. "$(dirname $0)/env"
cd $SRC

if ! test -d libpcap; then
    git clone --depth 1 -b $LIBPCAP_VERSION https://github.com/the-tcpdump-group/libpcap
fi

cd libpcap

autoreconf -fi
./configure \
    PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig" \
    --prefix="$PREFIX"

make -j$(nproc)
make install
