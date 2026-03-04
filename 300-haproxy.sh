#!/bin/bash

# May require extra capabilities see https://github.com/traviscross/mtr/blob/master/SECURITY

set -e
. "$(dirname $0)/env"
cd $SRC

if ! test -d haproxy; then
    git clone --depth 1 -b  $HAPROXY_VERSION https://github.com/haproxy/haproxy
fi
cd haproxy

# Detect haterm support (available since HAProxy 3.4)
_haterm=
if grep -q '^haterm' Makefile; then
    _haterm=haterm
fi

# openssl
make -j $(nproc) \
	TARGET=linux-glibc \
	USE_OPENSSL=1 \
        USE_QUIC=1 \
	SSL_INC="$PREFIX/openssl/include" \
	SSL_LIB="$PREFIX/openssl/lib64" \
        USE_PTHREAD_EMULATION=1 \
	ERR=1 \
	USE_CRYPT_H=1 \
	USE_ENGINE=1 \
	USE_GETADDRINFO=1 \
	USE_LIBCRYPT=1 \
	USE_LINUX_CAP=1 \
	USE_LUA=1 \
	USE_NS=1 \
	USE_PCRE2=1 \
	USE_PCRE2_JIT=1 \
	USE_PROMEX=1 \
	USE_SLZ=1 \
	USE_TFO=1 \
	USE_THREAD=1 \
	VERDATE="$(git log -1 --format=%at | xargs -I{} date -d @{} '+%Y/%m/%d')" \
	SUBVERS="$(git describe | cut -d - -f 3-)" all $_haterm

flavor=openssl
cp haproxy $PREFIX/bin/haproxy-$flavor
if test -n "$_haterm"; then
    cp haterm $PREFIX/bin/haterm-$flavor
fi
for l in libssl libcrypto; do
    patchelf --replace-needed $l.so $l-$flavor.so $PREFIX/bin/haproxy-$flavor
    if test -n "$_haterm"; then
        patchelf --replace-needed $l.so $l-$flavor.so $PREFIX/bin/haterm-$flavor
    fi
done

make -j $(nproc) \
	TARGET=linux-glibc \
	USE_OPENSSL_AWSLC=1 \
        USE_QUIC=1 \
	SSL_INC="$PREFIX/aws-lc/include" \
	SSL_LIB="$PREFIX/aws-lc/lib" \
        USE_PTHREAD_EMULATION=1 \
	ERR=1 \
	USE_CRYPT_H=1 \
	USE_ENGINE=1 \
	USE_GETADDRINFO=1 \
	USE_LIBCRYPT=1 \
	USE_LINUX_CAP=1 \
	USE_LUA=1 \
	USE_NS=1 \
	USE_PCRE2=1 \
	USE_PCRE2_JIT=1 \
	USE_PROMEX=1 \
	USE_SLZ=1 \
	USE_TFO=1 \
	USE_THREAD=1 \
	VERDATE="$(git log -1 --format=%at | xargs -I{} date -d @{} '+%Y/%m/%d')" \
	SUBVERS="$(git describe | cut -d - -f 3-)" all $_haterm

flavor=aws-lc
cp haproxy $PREFIX/bin/haproxy-$flavor
if test -n "$_haterm"; then
    cp haterm $PREFIX/bin/haterm-$flavor
fi
for l in libssl libcrypto; do
    patchelf --replace-needed $l.so $l-$flavor.so $PREFIX/bin/haproxy-$flavor
    if test -n "$_haterm"; then
        patchelf --replace-needed $l.so $l-$flavor.so $PREFIX/bin/haterm-$flavor
    fi
done
