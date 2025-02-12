#!/bin/bash
set -e
. "$(dirname $0)/env"
cd $SRC

if ! test -d patchelf; then
    git clone https://github.com/NixOS/patchelf 
fi

cd patchelf 
git checkout $PATCHELF_VERSION
./bootstrap.sh
./configure \
   LDFLAGS="--static $LDFLAGS" \
   --prefix=$PREFIX
make
make install
exit
./configure \
    PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig" \
    --prefix="$PREFIX"

make -j$(nproc)
make install
