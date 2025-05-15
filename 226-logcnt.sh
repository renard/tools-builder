#!/bin/bash
set -e
. "$(dirname $0)/env"
cd $SRC

if ! test -d logcnt; then
    git clone --depth 1 -b $LOGCNT_VERSION https://github.com/wtarreau/logcnt
fi 

cd logcnt
make clean
make 
cp src/logcnt src/loggen "$PREFIX/bin/"
