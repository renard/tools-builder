#!/bin/bash
set -e
. "$(dirname $0)/env"
cd $SRC

if ! test -d ramspeed; then
    git clone --depth 1 -b $RAMSPEED_VERSION https://github.com/wtarreau/ramspeed
fi 

cd ramspeed
make clean
make 
cp rambw ramlat ramwalk "$PREFIX/bin/"
