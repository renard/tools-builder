#!/bin/bash
set -e
. "$(dirname $0)/env"
cd $SRC

if ! test -d rsync; then
    git clone --depth 1 -b $RSYNC_VERSION https://github.com/RsyncProject/rsync 
fi
cd rsync

./configure \
    --disable-md2man \
    --disable-openssl \
    --prefix="$PREFIX"

make -j$(nproc)
make install
