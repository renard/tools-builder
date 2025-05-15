#!/bin/bash
set -e
. "$(dirname $0)/env"
cd $SRC

if ! test -d h1load; then
    git clone --depth 1 -b  $H1LOAD_VERSION https://github.com/wtarreau/h1load
fi

cd h1load
make clean
make SSL_CFLAGS="-I$PREFIX/include" SSL_LFLAGS="-Wl,-Bdynamic -L$PREFIX/lib -lssl -lcrypto -ldl"
cp h1load "$PREFIX/bin/"
