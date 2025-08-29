#!/bin/bash


set -e
. "$(dirname $0)/env"
cd $SRC

if ! test -d 7zip; then
   git clone --depth 1 -b $S_7ZIP_VERSION https://github.com/ip7z/7zip.git   
fi

cd 7zip 
cd CPP/7zip/Bundles/Alone2
make -f ../../cmpl_gcc.mak -j$(nproc)
cp -a b/g/7zz $PREFIX/bin/7z
