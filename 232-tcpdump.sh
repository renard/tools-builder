#!/bin/bash
set -e
. "$(dirname $0)/env"
cd $SRC

if ! test -d tcpdump; then
    git clone https://github.com/the-tcpdump-group/tcpdump 
fi

cd tcpdump 
git checkout $TCPDUMP_VERSION

./autogen.sh
./configure \
    PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig" \
    --prefix="$PREFIX"

make -j$(nproc)
make install
