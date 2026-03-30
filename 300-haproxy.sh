#!/bin/bash

# May require extra capabilities see https://github.com/traviscross/mtr/blob/master/SECURITY

set -e
. "$(dirname $0)/env"
cd $SRC

haproxy_git_url() {
    local version=$1
    if [[ $version == *dev* ]]; then
        echo "http://git.haproxy.org/git/haproxy.git"
    else
        local series=${version#v}   # v3.2.0 -> 3.2.0
        series=${series%.*}         # 3.2.0  -> 3.2
        echo "http://git.haproxy.org/git/haproxy-${series}.git"
    fi
}

install_flavor() {
    local version=$1 flavor=$2 haterm=$3
    cp haproxy $PREFIX/bin/haproxy-$version-$flavor
    if test -n "$haterm"; then
        cp haterm $PREFIX/bin/haterm-$version-$flavor
    fi
    for l in libssl libcrypto; do
        patchelf --replace-needed $l.so $l-$flavor.so $PREFIX/bin/haproxy-$version-$flavor
        if test -n "$haterm"; then
            patchelf --replace-needed $l.so $l-$flavor.so $PREFIX/bin/haterm-$version-$flavor
        fi
    done
}

for version in "${HAPROXY_VERSIONS[@]}"; do

    dir=haproxy-$version
    if ! test -d $dir; then
        git clone --depth 1 -b $version $(haproxy_git_url $version) $dir
    fi
    cd $dir

    # Detect haterm support (available since HAProxy 3.4)
    _haterm=
    grep -q '^haterm' Makefile && _haterm=haterm

    _verflags=(
        "VERDATE=$(git log -1 --format=%at | xargs -I{} date -d @{} '+%Y/%m/%d')"
        "SUBVERS=$(git describe | cut -d - -f 3-)"
    )

    # openssl
    make -j$(nproc) TARGET=linux-glibc \
        USE_OPENSSL=1 USE_QUIC=1 \
        SSL_INC="$PREFIX/openssl/include" SSL_LIB="$PREFIX/openssl/lib64" \
        USE_CRYPT_H=1 USE_ENGINE=1 \
        USE_LINUX_TPROXY=1 USE_LINUX_SPLICE=1 USE_CPU_AFFINITY=1 \
        USE_GETADDRINFO=1 USE_LIBCRYPT=1 USE_LINUX_CAP=1 USE_LUA=1 \
        USE_NS=1 USE_PCRE2=1 USE_PCRE2_JIT=1 USE_PROMEX=1 \
        USE_SLZ=1 USE_TFO=1 USE_THREAD=1 \
        "${_verflags[@]}" all $_haterm
    install_flavor $version openssl "$_haterm"

    # aws-lc
    make -j$(nproc) TARGET=linux-glibc \
        USE_OPENSSL_AWSLC=1 USE_QUIC=1 \
        SSL_INC="$PREFIX/aws-lc/include" SSL_LIB="$PREFIX/aws-lc/lib" \
        USE_CRYPT_H=1 USE_ENGINE=1 \
        USE_LINUX_TPROXY=1 USE_LINUX_SPLICE=1 USE_CPU_AFFINITY=1 \
        USE_GETADDRINFO=1 USE_LIBCRYPT=1 USE_LINUX_CAP=1 USE_LUA=1 \
        USE_NS=1 USE_PCRE2=1 USE_PCRE2_JIT=1 USE_PROMEX=1 \
        USE_SLZ=1 USE_TFO=1 USE_THREAD=1 \
        "${_verflags[@]}" all $_haterm
    install_flavor $version aws-lc "$_haterm"

    cd ..
done
