#!/bin/bash
set -e
. "$(dirname $0)/env"
cd $SRC

if ! test -d logcnt; then
    git clone https://github.com/wtarreau/logcnt
fi 

cd logcnt
make clean
make 
cp src/logcnt src/loggen "$PREFIX/bin/"
