#!/bin/bash
set -e
. "$(dirname $0)/env"
. "$(dirname $0)/functions"
cd $SRC

if ! test -d ngtcp2; then
    git clone --depth 1 -b $NGTCP2_VERSION https://github.com/ngtcp2/ngtcp2
fi

cd ngtcp2
git submodule update --init --depth 1
autoreconf -i

# ngtcp2 lib does not depend on OpenSSL

# ngtcp2 with aws-lc does not require any libssl nor libcrypto dependancy.
flavor=aws-lc
./configure --prefix=$PREFIX/$flavor --enable-lib-only  \
      --with-boringssl \
      BORINGSSL_CFLAGS="-I$PREFIX/$flavor/include" \
      BORINGSSL_LIBS="-L$PREFIX/$flavor/lib -lssl -lcrypto"
make -j$(nproc)
make install

cleanup_lib_version $PREFIX/$flavor/lib/libngtcp2.so
add_lib_variant $PREFIX/$flavor/lib/libngtcp2.so $PREFIX/lib $flavor


# ngtcp2 with openssl generates 2 extra libs.
flavor=openssl
./configure --prefix=$PREFIX/$flavor --enable-lib-only  \
      --with-openssl \
      PKG_CONFIG_PATH="$PREFIX/$flavor/lib/pkgconfig:$PREFIX/lib/pkgconfig"
make -j$(nproc)
make install

for l in libngtcp2 libngtcp2_crypto_ossl; do
    cleanup_lib_version $PREFIX/$flavor/lib64/$l.so
    add_lib_variant $PREFIX/$flavor/lib64/$l.so $PREFIX/lib $flavor
    for lssl in libssl libcrypto; do 
        patchelf --replace-needed $lssl.so $lssl-$flavor.so $PREFIX/lib/$l-$flavor.so
    done
done
patchelf --replace-needed libngtcp2.so.16 libngtcp2.so $PREFIX/$flavor/lib64/libngtcp2_crypto_ossl.so
patchelf --replace-needed libngtcp2.so.16 libngtcp2-$flavor.so $PREFIX/lib/libngtcp2_crypto_ossl-$flavor.so

LD_LIBRARY_PATH=$PREFIX/lib ldd $PREFIX/lib/libngtcp2_crypto_ossl-$flavor.so
