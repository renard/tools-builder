#!/bin/bash

# This script creates an archive of all built tools



set -e
. "$(dirname $0)/env"

mkdir -p $ARCHIVE
cp -a $PREFIX/bin/* $ARCHIVE
rm $ARCHIVE/curl-config* $ARCHIVE/pcap-config* $ARCHIVE/tcpdump.*

ldd $ARCHIVE/* | tr -s ' ' | sed -n 's,.*[[:space:]]\(/.*\)[[:space:]]\+(.*,\1,p' | sort |uniq | xargs cp -L -t $ARCHIVE
set -x
mv $ARCHIVE $ARCHIVE-$RELEASE
chmod 0644 $ARCHIVE-$RELEASE/*.so.* $ARCHIVE-$RELEASE/*.so
du -shc $ARCHIVE-$RELEASE
for f in $ARCHIVE-$RELEASE/*; do
    case $f in 
        */ld-linux-*) 
            chmod 755 $f
	    continue
	    ;;
    esac
    $ARCHIVE-$RELEASE/patchelf --set-rpath '$ORIGIN' $f || true
done
strip $ARCHIVE-$RELEASE/* || true
cat <<'EOF' > $ARCHIVE-$RELEASE/fix-interpreter
#!/bin/sh

# This scripts changes the binary interpreter to use the local ld-linux lib
# file. It should be run each time tool folder is deployed on a machine or
# moved on the file system.

interpreter=$(find $(dirname $0) -type f -executable -name 'ld-linux-*')

for f in $(find $(dirname $0) -regextype grep  -type f -executable -not -regex  '.*/\(ld-linux-.*\|fix-interpreter\|install-tools\|patchelf\)'); do
    $(dirname $0)/patchelf --set-interpreter "$interpreter" $f
done
EOF

cat <<'EOF' > $ARCHIVE-$RELEASE/install-tools
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

for f in $(find $(dirname $0) -regextype grep  -type f -executable -not -regex  '.*/\(ld-linux-.*\|fix-interpreter\|install-tools\|patchelf\)'); do
    ln -nfs $f $TARGET/$(basename $f)
done
EOF

chmod 755 $ARCHIVE-$RELEASE/fix-interpreter $ARCHIVE-$RELEASE/install-tools
du -shc $ARCHIVE-$RELEASE
tar -C $(dirname $ARCHIVE) -cvzf $ARCHIVE-$RELEASE.tgz $(basename $ARCHIVE)-$RELEASE

