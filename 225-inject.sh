#!/bin/bash
set -e
. "$(dirname $0)/env"
cd $SRC

if ! test -d inject; then
    git clone https://github.com/wtarreau/inject
fi 

cd inject
make clean
make 
cp inject "$PREFIX/bin/"
