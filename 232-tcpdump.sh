#!/bin/bash
set -e
. "$(dirname $0)/env"
. "$(dirname $0)/functions"
cd $SRC

if ! test -d tcpdump; then
    git clone --depth 1 -b $TCPDUMP_VERSION https://github.com/the-tcpdump-group/tcpdump 
fi

cd tcpdump 

# requires openssl

./autogen.sh
flavor=aws-lc
./configure \
    PKG_CONFIG_PATH="$PREFIX/$flavor/lib/pkgconfig:$PREFIX/lib/pkgconfig" \
    --prefix="$PREFIX/$flavor"

make -j$(nproc)
make install
cp -a $PREFIX/$flavor/bin/tcpdump $PREFIX/bin/tcpdump-$flavor
patchelf --replace-needed libcrypto.so libcrypto-$flavor.so $PREFIX/bin/tcpdump-$flavor
LD_LIBRARY_PATH=$PREFIX/lib/ $PREFIX/bin/tcpdump-$flavor -h


make clean
# TODO: factorize
flavor=openssl
./configure \
    PKG_CONFIG_PATH="$PREFIX/$flavor/lib/pkgconfig:$PREFIX/lib/pkgconfig" \
    --prefix="$PREFIX/$flavor"

make -j$(nproc)
make install
cp -a $PREFIX/$flavor/bin/tcpdump $PREFIX/bin/tcpdump-$flavor
patchelf --replace-needed libcrypto.so libcrypto-$flavor.so $PREFIX/bin/tcpdump-$flavor
LD_LIBRARY_PATH=$PREFIX/lib/ $PREFIX/bin/tcpdump-$flavor -h

