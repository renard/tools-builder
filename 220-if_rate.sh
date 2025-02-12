#!/bin/bash
set -e
. "$(dirname $0)/env"
cd $SRC

if ! test -d if_rate; then
    git clone https://github.com/wtarreau/if_rate
fi

cd if_rate 
make
cp bin/if_rate "$PREFIX/bin/"
