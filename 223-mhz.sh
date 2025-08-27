#!/bin/bash
set -e
. "$(dirname $0)/env"
cd $SRC

if ! test -d mhz; then
    git clone --depth 1 -b $MHZ_VERSION  https://github.com/wtarreau/mhz
fi 

cd mhz
make clean
make 
cp mhz "$PREFIX/bin/"
"$PREFIX/bin/mhz" -h
