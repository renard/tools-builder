#!/bin/bash


set -e
. "$(dirname $0)/env"
. "$(dirname $0)/functions"
cd $SRC

if ! test -d socat; then
    git clone --depth 1 -b $SOCAT_VERSION https://third-party-mirror.googlesource.com/socat
fi
cd socat

autoconf

# socat only support openss
for flavor in openssl; do
    ./configure \
        PKG_CONFIG_PATH="$PREFIX/$flavor/lib/pgkconfig:$PREFIX/lib/pkgconfig" \
        --prefix="$PREFIX/$flavor"

    make progs -j$(nproc)
    # fake manpage
    touch doc/socat.1
    make install

    remove_version_needed $PREFIX/$flavor/bin/socat libssl.so.3
    remove_version_needed $PREFIX/$flavor/bin/socat libcrypto.so.3

    cp -a $PREFIX/$flavor/bin/socat1 $PREFIX/bin/socat
    patchelf --replace-needed libssl.so libssl-$flavor.so $PREFIX/bin/socat
    patchelf --replace-needed libcrypto.so libcrypto-$flavor.so $PREFIX/bin/socat
    LD_LIBRARY_PATH=$PREFIX/lib $PREFIX/bin/socat -V
done
