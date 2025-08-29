#!/bin/bash

# This script will run all the builds in the debian chroot environment.

onerror() {
	umount $TARGET/home/build/$(basename $(dirname $0)) || true
}
trap 'onerror' ERR EXIT


. "$(dirname $0)/env"
TARGET=debian-$DEBIAN_VERSION


_dst=$TARGET/home/$BUILD_USER/$(basename $(dirname $0))


# If tools builder is not deployed in the chroot.
if ! test -e $_dst/env; then

	# First try to mount the tools-builder into the chroot
	mount -o bind,ro $(dirname $0) $_dst
	# In case of mount failure (such as in Github action) try to copy all build
	# files to the chroot.
	if test $? -ne 0; then
		tar --exclude="debian-$DEBIAN_VERSION" -cf - . \
			| (cd "debian-$DEBIAN_VERSION/home/$BUILD_USER" && tar -xf -)
	fi
fi


set -e
for f in $(dirname $0)/[1-9]*.sh; do
    chroot debian-bookworm sudo -u $BUILD_USER -i $f
done
#chroot debian-bookworm sudo -u build -i $(dirname $0)/998-archive.sh

mv $TARGET/$ARCHIVE-*.tgz .

