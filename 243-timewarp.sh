#!/bin/bash
set -e
. "$(dirname $0)/env"
cd $SRC

if ! test -d timewarp; then
  git clone --depth 1 -b $TIMEWARP_VERSION https://github.com/renard/timewarp
fi

cd timewarp
make clean
make
cp timewarp timewarp-ctl "$PREFIX/bin/"
