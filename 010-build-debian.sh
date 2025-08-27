#!/bin/bash

# This script creates a debian chroot environment used to run the builds.



set -e
. "$(dirname $0)/env"

TARGET=debian-$DEBIAN_VERSION
# libhttp-parser-dev
debootstrap \
    --arch 'amd64' \
    --components 'main,contrib,non-free' \
    --include='sudo,git,build-essential,autoconf,pkg-config,make,gcc,g++,cmake,libtool,libc-ares-dev,libevent-dev,libjansson-dev,libsystemd-dev,libxml2-dev,,libiberty-dev,zlib1g-dev,libjemalloc-dev,libev-dev,libpsl-dev,ca-certificates,automake,flex,bison,patchelf,libxxhash-dev,liblz4-dev,libzstd-dev,libncurses-dev,liblua5.4-dev,libpcre2-dev,libacl1-dev' \
    $DEBIAN_VERSION $TARGET \
    http://deb.debian.org/debian/

> $TARGET/etc/apt/sources.list
cat <<EOF > $TARGET/etc/apt/sources.list.d/deb_debian_org_debian.list
deb http://deb.debian.org/debian $DEBIAN_VERSION main contrib non-free
deb http://deb.debian.org/debian $DEBIAN_VERSION-updates main contrib non-free
deb http://deb.debian.org/debian $DEBIAN_VERSION-proposed-updates main contrib non-free
deb http://deb.debian.org/debian $DEBIAN_VERSION-backports main contrib non-free
deb http://deb.debian.org/debian $DEBIAN_VERSION-backports-sloppy main contrib non-free
deb http://deb.debian.org/debian-security $DEBIAN_VERSION-security/updates main contrib non-free
EOF

echo debian-$DEBIAN_VERSION > $TARGET/etc/debian_chroot


cat <<EOF | chroot $TARGET
adduser $BUILD_USER --uid $BUILD_UID --disabled-password --comment 'package builder agent'
groupmod -a -U $BUILD_USER sudo
cat <<EOF2 | EDITOR='tee -a' visudo -f /etc/sudoers.d/nopasswd
Defaults:root !requiretty, !use_pty
Defaults:%sudo !requiretty, !use_pty

%sudo ALL=(ALL:ALL) NOPASSWD: ALL
root ALL=(ALL:ALL) NOPASSWD: ALL
EOF2
sudo -u $BUILD_USER mkdir -p ~$BUILD_USER/src
sudo -u $BUILD_USER mkdir -p ~$BUILD_USER/$(basename $(dirname $0))
EOF
