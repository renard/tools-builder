#!/bin/bash
set -e
. "$(dirname $0)/env"
. "$(dirname $0)/functions"
cd $SRC


if ! test -d aws-lc; then 
    git clone --depth 1 -b $AWS_LC_VERSION https://github.com/aws/aws-lc
fi
cd aws-lc

flavor=aws-lc
cmake -B build \
    -DDISABLE_GO=ON \
    -DBUILD_SHARED_LIBS=1 \
    -DBUILD_TESTING=0 \
    --install-prefix=$PREFIX/$flavor

make -j$(nproc) -C build
cmake --install build

mkdir -p $PREFIX/{lib,bin}


for l in libssl libcrypto; do
    add_lib_variant $PREFIX/$flavor/lib/$l.so $PREFIX/lib $flavor
done

# replace SONAME libcrypto.so by libcrypto-$flavor.so in libssl-$flavor.so.
patchelf --replace-needed libcrypto.so libcrypto-$flavor.so $PREFIX/lib/libssl-$flavor.so

for b in bssl openssl; do
    cp -a $PREFIX/$flavor/bin/$b $PREFIX/bin/$b-$flavor
    for l in libssl libcrypto; do
        patchelf --replace-needed $l.so $l-$flavor.so $PREFIX/bin/$b-$flavor
    done
    # Check everything is OK
    LD_LIBRARY_PATH=$PREFIX/$flavor/lib  $PREFIX/$flavor/bin/$b version
    LD_LIBRARY_PATH=$PREFIX/lib  $PREFIX/bin/$b-$flavor version
done

