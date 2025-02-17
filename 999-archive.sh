#!/bin/bash

# This script creates an archive of all built tools



set -e
. "$(dirname $0)/env"

mkdir -p $ARCHIVE/bin $ARCHIVE/lib
cp -a $PREFIX/bin/* $ARCHIVE/bin
rm $ARCHIVE/bin/curl-config* $ARCHIVE/bin/pcap-config* $ARCHIVE/bin/tcpdump.* $ARCHIVE/bin/rsync-ssl

if test -z "$KEEP_NGHTTP_APPS"; then
	rm $ARCHIVE/bin/nghttp*
fi


LD_LIBRARY_PATH=$PREFIX/lib ldd $ARCHIVE/bin/* $ARCHIVE/lib/*| tr -s ' ' | sed -n 's,.*[[:space:]]\(/.*\)[[:space:]]\+(.*,\1,p' | sort |uniq | xargs cp -L -t $ARCHIVE/lib

chmod 0755 $ARCHIVE/bin/* 
mv $ARCHIVE/bin/patchelf $ARCHIVE

du -shc $ARCHIVE
$ARCHIVE/patchelf --set-rpath '$ORIGIN/../lib' $ARCHIVE/bin/*
for l in $(find $ARCHIVE/lib -regextype grep -type f -not -regex '.*/\(ld-linux-.*\)'); do
    $ARCHIVE/patchelf --set-rpath '$ORIGIN' $l
done
strip $ARCHIVE/bin/* $ARCHIVE/lib/* $ARCHIVE/patchelf
du -shc $ARCHIVE

cat <<'EOF' > $ARCHIVE/fix-interpreter
#!/bin/sh

# This scripts changes the binary interpreter to use the local ld-linux lib
# file. It should be run each time tool folder is deployed on a machine or
# moved on the file system.

mydir=$(dirname $(readlink -f $0))

interpreter=$(find $mydir/lib -type f -executable -name 'ld-linux-*')

for f in $(find $mydir/bin -type f -executable); do
    $mydir/patchelf --set-interpreter "$interpreter" $f
    $mydir/patchelf --set-rpath '$ORIGIN/../lib' $f
done

# Make sure all libraries but ld-linux use $ORIGIN as a search path
for l in $(find ./bench-tools/lib -regextype grep -type f -not -regex '.*/\(ld-linux-.*\)'); do
    $mydir/patchelf --set-rpath '$ORIGIN' $l
done
EOF

cat <<'EOF' > $ARCHIVE/install-tools
#!/bin/sh

# This script installs (creates symlinks) the binaries in a specific folder
# passed as an argument (by default it uses the current directory)
#
# Idealy links should be deployed in a directory defined in $PATH (such as
# /usr/local/bin).

TARGET=$1
if test -z "$TARGET"; then
  TARGET=.
fi

for f in $(find $(dirname $0)/bin -type f -executable); do
    ln -nfs $f $TARGET/$(basename $f)
done
EOF

chmod 755 $ARCHIVE/fix-interpreter $ARCHIVE/install-tools
mv $ARCHIVE $ARCHIVE-$RELEASE

tar -C $(dirname $ARCHIVE) -cvzf $ARCHIVE-$RELEASE.tgz $(basename $ARCHIVE)-$RELEASE

