#!/bin/bash
set -e
. "$(dirname $0)/env"
cd $SRC

if ! test -d httpterm; then
    git clone --depth 1 -b $HTTPTERM_VERSION https://github.com/wtarreau/httpterm
fi

cd httpterm
make clean
make 
cp httpterm "$PREFIX/bin/"
