#!/bin/bash
set -e
. "$(dirname $0)/env"
cd $SRC

if ! test -d tcpdump; then
    git clone --depth 1 -b $TCPDUMP_VERSION https://github.com/the-tcpdump-group/tcpdump 
fi

cd tcpdump 

./autogen.sh
./configure \
    PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig" \
    --prefix="$PREFIX"

make -j$(nproc)
make install
