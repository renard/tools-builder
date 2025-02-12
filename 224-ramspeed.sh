#!/bin/bash
set -e
. "$(dirname $0)/env"
cd $SRC

if ! test -d ramspeed; then
    git clone https://github.com/wtarreau/ramspeed
fi 

cd ramspeed
make clean
make 
cp rambw ramlat ramwalk "$PREFIX/bin/"
