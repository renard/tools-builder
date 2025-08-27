#!/bin/bash
set -e
. "$(dirname $0)/env"
. "$(dirname $0)/functions"
cd $SRC

if ! test -d rsync; then
    git clone --depth 1 -b $RSYNC_VERSION https://github.com/RsyncProject/rsync 
fi
cd rsync

# rsync only supports openssl
for flavor in  openssl; do
    # Force to use built openssl
    CPPFLAGS="-I$PREFIX/$flavor/include" \
		LDFLAGS="-L$PREFIX/$flavor/lib64" \
		./configure \
        --disable-md2man \
        --enable-openssl=$PREFIX/$flavor \
        --prefix="$PREFIX/$flavor"

    make -j$(nproc)
    make install

    LD_LIBRARY_PATH=$PREFIX/$flavor/lib $PREFIX/$flavor/bin/rsync -V

    cp -a  $PREFIX/$flavor/bin/rsync $PREFIX/bin/rsync-$flavor
    patchelf --replace-needed libcrypto.so libcrypto-$flavor.so $PREFIX/bin/rsync-$flavor
    LD_LIBRARY_PATH=$PREFIX/lib $PREFIX/bin/rsync-$flavor -V
done
