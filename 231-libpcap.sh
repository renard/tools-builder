#!/bin/bash
set -e
. "$(dirname $0)/env"
cd $SRC

if ! test -d libpcap; then
    git clone https://github.com/the-tcpdump-group/libpcap
fi

cd libpcap
git checkout $LIBPCAP_VERSION

autoreconf -fi
./configure \
    PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig" \
    --prefix="$PREFIX"

make -j$(nproc)
make install
