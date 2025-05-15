#!/bin/bash


set -e
. "$(dirname $0)/env"
cd $SRC

if ! test -d strace; then
    git clone https://github.com/strace/strace
fi
cd strace
git checkout $STRACE_VERSION

./bootstrap
./configure \
    --disable-mpers \
    --prefix="$PREFIX"

make -j$(nproc)
make install

