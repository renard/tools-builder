#!/bin/bash
set -e
. "$(dirname $0)/env"
. "$(dirname $0)/functions"
cd $SRC

if ! test -d openssl; then 
    git clone --depth 1 -b $OPENSSL_VERSION https://github.com/openssl/openssl
fi
cd openssl
git submodule update --init --depth 1

flavor=openssl
./Configure linux-x86_64 \
  --prefix="$PREFIX/$flavor" \
  --openssldir="$PREFIX/ssl"

make -j$(nproc)
make install_sw

mkdir -p $PREFIX/{lib,bin}
ln -nfs lib64 $PREFIX/$flavor/lib


cleanup_lib_version $PREFIX/$flavor/lib64/libcrypto.so
cleanup_lib_version $PREFIX/$flavor/lib64/libssl.so
patchelf --replace-needed libcrypto.so.3 libcrypto.so $PREFIX/$flavor/lib64/libssl.so

add_lib_variant $PREFIX/$flavor/lib64/libcrypto.so $PREFIX/lib $flavor
add_lib_variant $PREFIX/$flavor/lib64/libssl.so $PREFIX/lib $flavor
# Fix libcrypto dependancey in taget
patchelf --replace-needed libcrypto.so libcrypto-openssl.so $PREFIX/lib/libssl-openssl.so

# Fix binaries
for b in openssl; do
    cp -av $PREFIX/$flavor/bin/$b $PREFIX/bin/$b-$flavor
    for l in libssl libcrypto; do
        patchelf --replace-needed $l.so.3 $l.so $PREFIX/$flavor/bin/$b
        patchelf --replace-needed $l.so.3 $l-$flavor.so $PREFIX/bin/$b-$flavor
    done
    LD_LIBRARY_PATH=$PREFIX/$flavor/lib  $PREFIX/$flavor/bin/$b version
    LD_LIBRARY_PATH=$PREFIX/lib  $PREFIX/bin/$b-$flavor version
done
