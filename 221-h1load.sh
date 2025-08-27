#!/bin/bash
set -e
. "$(dirname $0)/env"
cd $SRC

if ! test -d h1load; then
    git clone --depth 1 -b  $H1LOAD_VERSION https://github.com/wtarreau/h1load
fi

cd h1load
for flavor in aws-lc openssl; do
    make clean
    make SSL_CFLAGS="-I$PREFIX/$flavor/include" SSL_LFLAGS="-Wl,-Bdynamic -L$PREFIX/$flavor/lib -lssl -lcrypto -ldl"
    cp h1load "$PREFIX/bin/h1load-$flavor"
    for l in libssl libcrypto; do
       patchelf --replace-needed $l.so $l-$flavor.so $PREFIX/bin/h1load-$flavor
    done
    LD_LIBRARY_PATH=$PREFIX/lib $PREFIX/bin/h1load-$flavor -h
done
