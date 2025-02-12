#!/bin/bash
set -e
. "$(dirname $0)/env"
cd $SRC


if ! test -d aws-lc; then 
    git clone --depth 1 -b $AWS_LC_VERSION https://github.com/aws/aws-lc
fi
cd aws-lc
cmake -B build -DDISABLE_GO=ON -DBUILD_SHARED_LIBS=1 -DBUILD_TESTING=0 --install-prefix=$PREFIX
make -j$(nproc) -C build
cmake --install build

