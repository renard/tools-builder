#!/bin/bash
set -e
. "$(dirname $0)/env"
. "$(dirname $0)/functions"
cd $SRC

if ! test -d curl; then
    git clone --depth 1 -b  $CURL_VERSION https://github.com/curl/curl
fi

cd curl

autoreconf -fi

# need:
#  apt-get install libldap-dev
#  apt-get install libssh2-1-dev
#  apt-get install libbrotli-dev
#  apt-get install libgsasl-dev
#  apt-get install libgss-dev
#  apt-get install librtmp-dev
#  apt-get install libkrb5-dev

# aws-lc
flavor=aws-lc
PKG_CONFIG_PATH="$PREFIX/$flavor/lib/pkgconfig:$PREFIX/lib/pkgconfig" \
./configure \
    --with-libssh2 \
    --with-gssapi \
    --enable-httpsrr \
    --enable-ech \
    --enable-ssls-export \
    --with-openssl="$PREFIX/$flavor" \
    --with-nghttp3="$PREFIX" \
    --with-ngtcp2="$PREFIX/$flavor" \
    --prefix="$PREFIX/$flavor"
make -j$(nproc)
make install #-strip


cleanup_lib_version "$PREFIX/$flavor/lib/libcurl.so"
add_lib_variant $PREFIX/$flavor/lib/libcurl.so $PREFIX/lib $flavor
remove_version_needed $PREFIX/$flavor/bin/curl libcurl.so.4
cp $PREFIX/$flavor/bin/curl $PREFIX/bin/curl-$flavor

patchelf --replace-needed libcurl.so libcurl-$flavor.so  $PREFIX/bin/curl-$flavor

#for l in libssl libcrypto libnghttp2 libngtcp2; do
for l in libssl libcrypto libnghttp2 libngtcp2_crypto_ossl libngtcp2; do
    patchelf --replace-needed $l.so $l-$flavor.so  $PREFIX/lib/libcurl-$flavor.so
done


make clean
flavor=openssl


PKG_CONFIG_PATH="$PREFIX/$flavor/lib/pkgconfig:$PREFIX/lib/pkgconfig" \
./configure \
    --with-libssh2 \
    --with-gssapi \
    --enable-httpsrr \
    --enable-ssls-export \
    --with-openssl="$PREFIX/$flavor" \
    --with-nghttp3="$PREFIX" \
    --with-ngtcp2="$PREFIX/$flavor" \
    --prefix="$PREFIX/$flavor"

make -j$(nproc)
make install #-strip


cleanup_lib_version "$PREFIX/$flavor/lib/libcurl.so"
add_lib_variant $PREFIX/$flavor/lib/libcurl.so $PREFIX/lib $flavor
remove_version_needed $PREFIX/$flavor/bin/curl libcurl.so.4
cp $PREFIX/$flavor/bin/curl $PREFIX/bin/curl-$flavor

patchelf --replace-needed libcurl.so libcurl-$flavor.so  $PREFIX/bin/curl-$flavor

#for l in libssl libcrypto libnghttp2 libngtcp2; do
for l in libssl libcrypto libnghttp2 libngtcp2_crypto_ossl libngtcp2; do
    patchelf --replace-needed $l.so $l-$flavor.so  $PREFIX/lib/libcurl-$flavor.so
done
