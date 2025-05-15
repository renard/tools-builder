#!/bin/bash
set -e
. "$(dirname $0)/env"
cd $SRC

if ! test -d inject; then
    git clone  --depth 1 -b $INJECT_VERSION https://github.com/wtarreau/inject
fi 

cd inject
make clean
make 
cp inject "$PREFIX/bin/"
