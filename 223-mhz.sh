#!/bin/bash
set -e
. "$(dirname $0)/env"
cd $SRC

if ! test -d mhz; then
    git clone https://github.com/wtarreau/mhz
fi 

cd mhz
make clean
make 
cp mhz "$PREFIX/bin/"
