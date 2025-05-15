#!/bin/bash
set -e
. "$(dirname $0)/env"
cd $SRC

if ! test -d rsync; then
    git clone https://github.com/RsyncProject/rsync 
fi
cd rsync
git checkout $RSYNC_VERSION

./configure \
    --disable-md2man \
    --disable-openssl \
    --prefix="$PREFIX"

make -j$(nproc)
make install
