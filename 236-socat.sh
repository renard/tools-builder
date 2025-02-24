#!/bin/bash


set -e
. "$(dirname $0)/env"
cd $SRC

if ! test -d socat; then
    git clone https://repo.or.cz/socat.git 
fi
cd socat

autoconf
./configure \
    --prefix="$PREFIX"

make progs -j$(nproc)
# fake manpage
touch doc/socat.1
make install
mv $PREFIX/bin/socat1 $PREFIX/bin/socat
