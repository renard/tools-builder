#!/bin/bash


set -e
. "$(dirname $0)/env"
cd $SRC

if ! test -d fio; then
    git clone --depth 1 -b $FIO_VERSION git://git.kernel.dk/fio.git
fi
cd fio

# apt-get install libiscsi-dev libnfs-dev

## ndb requires libicudata.so 30Mb 
## ASAN requires 8Mb
./configure \
    --prefix=$PREFIX \
    --enable-libnfs \
    --enable-libiscsi
make -j$(nproc)
make install mandir=$PREFIX/share/man

