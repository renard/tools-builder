#!/bin/bash


set -e
. "$(dirname $0)/env"
cd $SRC

if ! test -d mandoc; then
   curl https://mandoc.bsd.lv/snapshots/mandoc-$MANDOC_VERSION.tar.gz | tar xvzf - --transform "s/mandoc-$MANDOC_VERSION/mandoc/" 

   # Ensures MANDIR is ../man relatively to man real path 
   cat <<'EOF' | patch -p0
--- mandoc/main.c	2021-09-23 18:03:23.000000000 +0000
+++ mandoc/main.c	2025-08-28 11:45:39.582160077 +0000
@@ -46,6 +46,7 @@
 #include <termios.h>
 #include <time.h>
 #include <unistd.h>
+#include <libgen.h>
 
 #include "mandoc_aux.h"
 #include "mandoc.h"
@@ -177,6 +178,21 @@
 		errx((int)MANDOCLEVEL_SYSERR, "sandbox_init");
 #endif
 
+	/* Lookup man pages relative to binary in ../man */
+	if (getenv("MANPATH") == NULL) {
+		char exe[PATH_MAX];
+		ssize_t len;
+		len = readlink("/proc/self/exe", exe, sizeof(exe) - 1);
+		if (len > 0) {
+			exe[len] = '\0';
+			char *dir = dirname(exe);
+			char relpath[PATH_MAX];
+			snprintf(relpath, sizeof(relpath), "%s/../man", dir);
+			setenv("MANPATH", relpath,1);
+		}
+	}
+
+
 	/* Search options. */
 
 	memset(&conf, 0, sizeof(conf));
@@ -822,8 +838,10 @@
 	return globres;
 
 found:
+	/*
 	warnx("outdated mandoc.db lacks %s(%s) entry, run %s %s",
 	    name, sec, BINM_MAKEWHATIS, paths->paths[ipath]);
+	*/
 	if (res == NULL)
 		free(file);
 	else if (file == NULL)
EOF

fi

cd mandoc


./configure 
make
cp -a man $PREFIX/binbt
cp man.1 $PREFIX/share/man/manbt.1
