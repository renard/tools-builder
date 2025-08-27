#!/bin/bash
set -e
. "$(dirname $0)/env"
. "$(dirname $0)/functions"
cd $SRC

if ! test -d nghttp2; then
    git clone --depth 1 -b $NGHTTP2_VERSION https://github.com/nghttp2/nghttp2 
fi

cd nghttp2
git submodule update --init --depth 1
autoreconf -i

## todo: Add support for --with-libbpf

flavor=openssl
    ./configure --enable-http3 --enable-app \
          --prefix=$PREFIX/$flavor \
          PKG_CONFIG_PATH="$PREFIX/$flavor/lib/pkgconfig:$PREFIX/lib/pkgconfig" \
	  --with-openssl=$PREFIX/$flavor
    make -j$(nproc)
    make install

    cleanup_lib_version $PREFIX/$flavor/lib64/libnghttp2.so
    add_lib_variant $PREFIX/$flavor/lib64/libnghttp2.so $PREFIX/lib $flavor
    for b in nghttp nghttpd nghttpx h2load inflatehd deflatehd; do
        $PREFIX/$flavor/bin/$b -h >/dev/null
	for l in libnghttp2.so.14 libnghttp3.so.9; do
	    remove_version_needed $PREFIX/$flavor/bin/$b $l
	done
        cp -av $PREFIX/$flavor/bin/$b $PREFIX/bin/$b-$flavor
	for l in libssl libcrypto libnghttp2 libngtcp2_crypto_ossl libngtcp2 ; do
    	    patchelf --replace-needed $l.so $l-$flavor.so $PREFIX/bin/$b-$flavor
	done
	LD_LIBRARY_PATH=$PREFIX/lib $PREFIX/bin/$b-$flavor -h >/dev/null


    done

flavor=aws-lc
    ./configure --enable-http3 --enable-app \
          --prefix=$PREFIX/$flavor \
          PKG_CONFIG_PATH="$PREFIX/$flavor/lib/pkgconfig:$PREFIX/lib/pkgconfig"
    
    make -j$(nproc)
    make install
    cleanup_lib_version $PREFIX/$flavor/lib/libnghttp2.so
    add_lib_variant $PREFIX/$flavor/lib/libnghttp2.so $PREFIX/lib $flavor

    # TODO: factorize
    for b in nghttp nghttpd nghttpx h2load inflatehd deflatehd; do
        $PREFIX/$flavor/bin/$b -h >/dev/null
	for l in libnghttp2.so.14 libnghttp3.so.9; do
	    remove_version_needed $PREFIX/$flavor/bin/$b $l
	done
        cp -av $PREFIX/$flavor/bin/$b $PREFIX/bin/$b-$flavor
	for l in libssl libcrypto libnghttp2 libngtcp2_crypto_ossl libngtcp2 ; do
    	    patchelf --replace-needed $l.so $l-$flavor.so $PREFIX/bin/$b-$flavor
	done
	LD_LIBRARY_PATH=$PREFIX/lib $PREFIX/bin/$b-$flavor -h >/dev/null


    done
