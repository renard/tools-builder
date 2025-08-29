#!/bin/bash


set -e
. "$(dirname $0)/env"
cd $SRC

if ! test -d jq; then
    git clone --depth 1 -b $JQ_VERSION https://github.com/jqlang/jq
fi
cd jq 

git submodule update --init --depth 1

autoreconf -fi
./configure \
    --prefix=$PREFIX \
    --disable-docs
make -j$(nproc)
make install

