#!/bin/bash
set -e
. "$(dirname $0)/env"
cd $SRC

if ! test -d httpterm; then
    git clone https://github.com/wtarreau/httpterm
fi

cd httpterm
make clean
make 
cp httpterm "$PREFIX/bin/"
