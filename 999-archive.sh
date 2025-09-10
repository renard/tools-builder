#!/bin/bash

# This script creates an archive of all built tools



set -e
. "$(dirname $0)/env"

mkdir -p $ARCHIVE/bin $ARCHIVE/lib
cp -a $PREFIX/bin/* $ARCHIVE/bin
rm -f \
    $ARCHIVE/bin/c_rehash* \
    $ARCHIVE/bin/curl-config* \
    $ARCHIVE/bin/onig-config \
    $ARCHIVE/bin/pcap-config* \
    $ARCHIVE/bin/tcpdump.* \
    $ARCHIVE/bin/rsync-ssl \
    $ARCHIVE/bin/socat*.sh \
    $ARCHIVE/bin/strace-log-merge \
    $ARCHIVE/bin/fio2gnuplot \
    $ARCHIVE/bin/fio_generate_plots \
    $ARCHIVE/bin/fio_jsonplus_clat2csv \
    $ARCHIVE/bin/fiologparser.py \
    $ARCHIVE/bin/fiologparser_hist.py \
    $ARCHIVE/bin/fio-histo-log-pctiles.py \
    $ARCHIVE/bin/genfio 

if test -z "$KEEP_NGHTTP_APPS"; then
	rm -f $ARCHIVE/bin/nghttp*
fi

mv $ARCHIVE/bin/patchelf $ARCHIVE
chmod 0755 $ARCHIVE/bin/* 

LD_LIBRARY_PATH=$PREFIX/lib ldd $ARCHIVE/bin/* $PREFIX/lib/*.so | tr -s ' ' | sed -n 's,.*[[:space:]]\(/.*\)[[:space:]]\+(.*,\1,p' | sort |uniq | xargs cp -L -t $ARCHIVE/lib


du -shc $ARCHIVE
$ARCHIVE/patchelf --set-rpath '$ORIGIN/../lib' $ARCHIVE/bin/*
for l in $(find $ARCHIVE/lib -regextype grep -type f -not -regex '.*/\(ld-linux-.*\)'); do
    $ARCHIVE/patchelf --set-rpath '$ORIGIN' $l
done

# Do not strip libraries to prevent issues with some commands such as:
#
#  error while loading shared libraries: libcurl-aws-lc.so: ELF load command
#  address/offset not page-aligned
strip $ARCHIVE/bin/*  $ARCHIVE/patchelf
du -shc $ARCHIVE

for i in 1 5 7 8; do
    mkdir -p $ARCHIVE/man/man$i
    cp -a $PREFIX/{.,aws-lc,openssl}/share/man/man$i/* $ARCHIVE/man/man$i || true
done

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

# Set haproxy capabilities if user is root
if test $(id -u) -eq 0; then
    for f in $(find $mydir/bin -type f -executable -name 'haproxy-*'); do
        # binary must be own by root for the capabilities to be effective
        chown root:root $f
        # when executed in secure mode (with capabilities for example) the
        # dynamic linker ignores $ORIGIN in RPATH (see ld.so(8)). One solition
        # is to use an absolute rpath. The binary is then not fully relocable
        # and fix-interpreter should be re-run if the files are moved.
        $mydir/patchelf --set-rpath "$mydir/lib" $f
        # Set haproxy capabilities to:
        #  - cap_net_bind_service: bind to privileged ports.
        #  - cap_net_raw: allow raw sockets (transparent proxy).
        setcap 'cap_net_bind_service,cap_net_raw=ep' $f
    done
fi

# Make sure all libraries but ld-linux use $ORIGIN as a search path
for l in $(find $mydir/lib -regextype grep -type f -not -regex '.*/\(ld-linux-.*\)'); do
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

