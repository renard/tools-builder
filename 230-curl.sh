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




# aws-lc

flavor=aws-lc
# Do no compile aws-lc with libssh to prevent clash with libcrypto

#  333  apt-get install libldap-dev
#  335  apt-get install libssh2-1-dev
#  337  apt-get install libgsasl-dev
#  341  apt-get install libgss-dev
#  345  apt-get install libidn2-dev
#  349  apt-get install librtmp-dev
#  353  apt-get install curl
#  361  apt-get install libkrb5-dev

#    --with-gsasl \
#    --with-libidn2 \
#    --enable-httpsrr \
#    --enable-ech \
#    --enable-ssls-export \
#    --with-gssapi \

./configure \
    PKG_CONFIG_PATH="$PREFIX/$flavor/lib/pkgconfig:$PREFIX/lib/pkgconfig" \
    --without-gsasl \
    --without-libidn2 \
    --disable-httpsrr \
    --disable-ech \
    --disable-ssls-export \
    --without-gssapi \
    --with-openssl="$PREFIX/$flavor" \
    --with-nghttp3="$PREFIX" \
    --with-ngtcp2="$PREFIX/$flavor" \
    --prefix="$PREFIX/$flavor"
make -j$(nproc)
make install-strip
cleanup_lib_version "$PREFIX/$flavor/lib/libcurl.so"
add_lib_variant $PREFIX/$flavor/lib/libcurl.so $PREFIX/lib $flavor


remove_version_needed $PREFIX/$flavor/bin/curl libnghttp2.so.14
remove_version_needed $PREFIX/$flavor/bin/curl libcurl.so.4

cp $PREFIX/$flavor/bin/curl $PREFIX/bin/curl-$flavor
patchelf --replace-needed libcurl.so libcurl-$flavor.so  $PREFIX/bin/curl-$flavor

for l in libssl libcrypto libnghttp2 libngtcp2_crypto_ossl libngtcp2 ; do
    patchelf --replace-needed $l.so $l-$flavor.so $PREFIX/lib/libcurl-$flavor.so
    patchelf --replace-needed $l.so $l-$flavor.so $PREFIX/bin/curl-$flavor
done

LD_LIBRARY_PATH=$PREFIX/$flavor/lib $PREFIX/$flavor/bin/curl -V
LD_LIBRARY_PATH=$PREFIX/lib $PREFIX/bin/curl-$flavor -V


make clean
flavor=openssl


    # --with-libssh2 \
./configure \
    PKG_CONFIG_PATH="$PREFIX/$flavor/lib/pkgconfig:$PREFIX/lib/pkgconfig" \
    --with-openssl="$PREFIX/$flavor" \
    --without-gsasl \
    --without-libidn2 \
    --disable-httpsrr \
    --disable-ech \
    --disable-ssls-export \
    --without-gssapi \
    --with-nghttp3="$PREFIX" \
    --with-ngtcp2="$PREFIX/$flavor" \
    --prefix="$PREFIX/$flavor"


make -j$(nproc)
make install-strip


# TODO: factorze
cleanup_lib_version "$PREFIX/$flavor/lib/libcurl.so"
add_lib_variant $PREFIX/$flavor/lib/libcurl.so $PREFIX/lib $flavor


remove_version_needed $PREFIX/$flavor/bin/curl libnghttp2.so.14
remove_version_needed $PREFIX/$flavor/bin/curl libcurl.so.4

cp $PREFIX/$flavor/bin/curl $PREFIX/bin/curl-$flavor
patchelf --replace-needed libcurl.so libcurl-$flavor.so  $PREFIX/bin/curl-$flavor

for l in libssl libcrypto libnghttp2 libngtcp2_crypto_ossl libngtcp2 ; do
    patchelf --replace-needed $l.so $l-$flavor.so $PREFIX/lib/libcurl-$flavor.so
    patchelf --replace-needed $l.so $l-$flavor.so $PREFIX/bin/curl-$flavor
done

LD_LIBRARY_PATH=$PREFIX/$flavor/lib $PREFIX/$flavor/bin/curl -V
LD_LIBRARY_PATH=$PREFIX/lib $PREFIX/bin/curl-$flavor -V



