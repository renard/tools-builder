#!/bin/bash


set -e
. "$(dirname $0)/env"
. "$(dirname $0)/functions"
cd $SRC

if ! test -d nmap; then
    git clone --depth 1 -b $NMAP_VERSION https://github.com/nmap/nmap 
fi
cd nmap

# nmap only supports openssl
for flavor in openssl; do
    ./configure \
        PKG_CONFIG_PATH="$PREFIX/$flavor/lib/pgkconfig:$PREFIX/lib/pkgconfig" \
        CFLAGS="-I$PREFIX/include -L$PREFIX/lib" \
        --prefix="$PREFIX/$flavor"
    
    make -j$(nproc)
    make install
    
    for b in nmap ncat nping; do
        for l in libssl.so.3 libcrypto.so.3; do 
            remove_version_needed $PREFIX/$flavor/bin/$b $l
        done

        # Do not flavor the binary
        cp -a $PREFIX/$flavor/bin/$b $PREFIX/bin/$b
        patchelf --replace-needed libcrypto.so libcrypto-$flavor.so $PREFIX/bin/$b
        patchelf --replace-needed libssl.so libssl-$flavor.so $PREFIX/bin/$b
    done
    LD_LIBRARY_PATH=$PREFIX/lib $PREFIX/bin/nmap -v
    
done
