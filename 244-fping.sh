#!/bin/bash
set -e
. "$(dirname $0)/env"
cd $SRC

if ! test -d fping; then
  git clone --depth 1 -b $FPING_VERSION https://github.com/schweikert/fping.git 
fi

cd fping
./autogen.sh
./configure \
   --sbindir="$PREFIX/bin" \
   --prefix="$PREFIX"
make -j$(nproc)
make install
