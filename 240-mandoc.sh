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
@@ -177,6 +178,22 @@
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
+                        printf("search in %s\n", relpath);
+		}
+	}
+
+
 	/* Search options. */
 
 	memset(&conf, 0, sizeof(conf));
@@ -187,7 +204,10 @@
 	search.outkey = "Nd";
 	oarg = NULL;
 
-	if (strcmp(progname, BINM_MAN) == 0)
+	if (strcmp(progname, BINM_MAN) == 0 ||
+            // man is named manbt as per man bench tool to not
+            // interfer with system man command
+            strcmp(progname, "manbt") == 0)
 		search.argmode = ARG_NAME;
 	else if (strcmp(progname, BINM_APROPOS) == 0)
 		search.argmode = ARG_EXPR;
@@ -208,7 +228,9 @@
 
 	memset(&outst, 0, sizeof(outst));
 	outst.tag_files = NULL;
-	outst.outtype = OUTT_LOCALE;
+        // render correctly non ascii chars
+	outst.outtype = OUTT_ASCII;
+	//        setenv("LESSCHARSET", "utf-8", 0);
 	outst.use_pager = 1;
 
 	show_usage = 0;
@@ -822,8 +844,10 @@
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
make -j$(nproc)
cp -a man $PREFIX/bin/manbt
mkdir -p $PREFIX/share/man/man1
cp man.1 $PREFIX/share/man/man1/manbt.1
