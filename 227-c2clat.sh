#!/bin/bash
set -e
. "$(dirname $0)/env"
cd $SRC

if ! test -d c2clat; then
    git clone --depth 1 -b  $C2CLAT_VERSION https://github.com/rigtorp/c2clat 
fi 

cd c2clat 
g++ -O3 -DNDEBUG c2clat.cpp -o c2clat -pthread
cp c2clat "$PREFIX/bin/"
