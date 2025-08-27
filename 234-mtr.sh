#!/bin/bash

# May require extra capabilities see https://github.com/traviscross/mtr/blob/master/SECURITY

set -e
. "$(dirname $0)/env"
cd $SRC

if ! test -d mtr; then
    git clone --depth 1 -b $MTR_VERSION https://github.com/traviscross/mtr 
fi
cd mtr 

./bootstrap.sh
./configure \
    --without-gtk \
    --sbindir="$PREFIX/bin" \
    --prefix="$PREFIX"

make -j$(nproc)
make install
