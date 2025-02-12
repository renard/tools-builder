#!/bin/bash

# This script will run all the builds in the debian chroot environment.

onerror() {
  umount $TARGET/home/build/$(basename $(dirname $0))
}
trap 'onerror' ERR EXIT



set -e
. "$(dirname $0)/env"
TARGET=debian-$DEBIAN_VERSION

mount -o bind,ro $(dirname $0) $TARGET/home/build/$(basename $(dirname $0))
set -x
for f in $(dirname $0)/[1-9]*.sh; do
    chroot debian-bookworm sudo -u build -i $f
done
#chroot debian-bookworm sudo -u build -i $(dirname $0)/998-archive.sh

mv $TARGET/$ARCHIVE-*.tgz .

