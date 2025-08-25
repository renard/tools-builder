#!/bin/bash


set -e
. "$(dirname $0)/env"
cd $SRC

if ! test -d jq; then
    git clone https://github.com/jqlang/jq
fi
cd jq 
git checkout $JQ_VERSION
git submodule update --init --depth 1

autoreconf -fi
./configure \
    --prefix=$PREFIX \
    --disable-docs
make -j$(nproc)
make install

