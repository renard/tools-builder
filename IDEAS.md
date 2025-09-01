# Other tools to consider

## thttpd

https://github.com/Cloudxtreme/thttpd

Tiny HTTP daemon to serve static pages. Is that really useful?

## faketime

https://github.com/wolfcw/libfaketime

Change system time resolution.

Only works using the faketime.so.1 as preloaded lib and for binaries provided by bench-tool:

```
LD_PRELOAD=/path/to/lib/libfaketime.so.q FAKETIME='YYYY-mm-dd HH:MM:SS' /path/to/bin/command
```

Following patch was tried but ended up with segfault when trying to
use the conveniant `faketime` command.


```diff
--- /src/faketime.c	2025-08-30 14:00:00.696574054 +0000
+++ /src/faketime.c	2025-08-30 13:40:36.622770930 +0000
@@ -45,6 +45,8 @@
 #include <sys/wait.h>
 #include <sys/mman.h>
 #include <semaphore.h>
+#include <libgen.h>
+#include <limits.h>

 #include "faketime_common.h"

@@ -362,6 +364,9 @@
     {
       char *ld_preload_new, *ld_preload = getenv("LD_PRELOAD");
       size_t len;
+      char exe[PATH_MAX];
+      ssize_t lenexe;
+      lenexe = readlink("/proc/self/exe", exe, sizeof(exe) - 1);
       if (use_mt)
       {
         /*
@@ -372,6 +377,13 @@
 #else
         ftpl_path = PREFIX "/$LIB/faketime/libfaketimeMT.so.1";
 #endif
+        if (lenexe > 0) {
+            exe[lenexe] = '\0';
+            char *dir = dirname(exe);
+            char tmp[PATH_MAX];
+            snprintf(tmp, sizeof(tmp), "%s/../lib/libfaketimeMT.so.1", dir);
+            ftpl_path = strdup(tmp);
+        }
       }
       else
       {
@@ -380,6 +392,14 @@
 #else
         ftpl_path = PREFIX "/$LIB/faketime/libfaketime.so.1";
 #endif
+        if (lenexe > 0) {
+            exe[lenexe] = '\0';
+            char *dir = dirname(exe);
+            char tmp[PATH_MAX];
+            snprintf(tmp, sizeof(tmp), "%s/../lib/libfaketimeMT.so.1", dir);
+            ftpl_path = strdup(tmp);
+        }
+
       }
       len = ((ld_preload)?strlen(ld_preload) + 1: 0) + 1 + strlen(ftpl_path);
       ld_preload_new = malloc(len);
```


One solution is to build `faketime` satically. But still only binaries
from the benchtool can be run by faketime.

```
make *.so.1
make faketime  CC="gcc -static"
```

```
#!/bin/bash


set -e
. "$(dirname $0)/env"
cd $SRC

if ! test -d libfaketime; then
   git clone --depth 1 -b $FAKETIME_VERSION https://github.com/wolfcw/libfaketime
fi

cd libfaketime
cd src
#make #cd srccd srccd srddc PREFIX=$PREFIX
#make install PREFIX=$PREFIX
make libfaketime.so.1 libfaketimeMT.so.1
make faketime  CC="gcc -static"
cd ..
cp -a src/libfaketime.so.1  src/libfaketimeMT.so.1 $PREFIX/lib
## Do not forget to remove libfaketime.so.1 and libfaketimeMT.so.1 needed from faketime
patchelf --add-needed libfaketimeMT.so.1 $PREFIX/bin/faketime
patchelf --add-needed libfaketime.so.1 $PREFIX/bin/faketime
```
