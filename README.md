# tools-builder

This repository contains a list of scripts that build relocatable
binaries.

The goal is to have tools to perform benchmarks on different machines
without having to rebuild them for all environments.


## Workflow

* A Debian chroot is create to build all binaries in a sandbox.

* Tools are downloaded from their official git repos and built in the
  sandbox.

* An archive of relocatable binaries is created.

## Tools

* Libs:

  * AWS-LC (https://github.com/aws/aws-lc)
  * HTTP3 support (https://github.com/ngtcp2/nghttp3)
  * HTTP2 support (https://github.com/nghttp2/nghttp2)

* taffic generator:

  * h1load (https://github.com/wtarreau/h1load)
  * h2load (https://github.com/ngtcp2/ngtcp2) with http3 support
  * curl (https://github.com/curl/curl) with http3 support
  * syslog injectors (https://github.com/wtarreau/logcnt)
  * inject (https://github.com/wtarreau/inject)

* Proxys

  * HAProxy (https://github.com/haproxy/haproxy)

* Servers:

  * httpterm (https://github.com/wtarreau/httpterm)
  * syslog server (https://github.com/wtarreau/logcnt)


* monitoring:

  * if_rate (https://github.com/wtarreau/if_rate)
  * c2clat (https://github.com/rigtorp/c2clat )
  * mhz (https://github.com/wtarreau/mhz)
  * ram latency (https://github.com/wtarreau/ramspeed)
  * tcpdump (https://github.com/the-tcpdump-group/tcpdump)

* other tools

  * nmap (https://github.com/nmap/nmap )
  * strace (https://github.com/strace/strace)
  * socat (https://repo.or.cz/socat.git, mirror: https://third-party-mirror.googlesource.com/socat/)
  * jq (https://github.com/jqlang/jq)
  * fio (https://git.kernel.dk/cgit/fio/, mirror: https://github.com/axboe/fio)
  * mandoc (https://mandoc.bsd.lv/snapshots). Renamed to `manbt` to prevent from system command clash.
  * 7zip (https://github.com/ip7z/7zip)
  * jwt-cli (https://github.com/mike-engel/jwt-cli/)[1].


[1] - Cargo takes too long to compile. jwt binary is retrieved from a
pre-build archive and made ready to use with provided libs for a
proper relocation.

## Howto

* Deploy this repository on a Debian Linux host and run the
  `000-build.sh` script.

* A `bench-tools-DATE.tgz` archive is generated

* Unarchive the `bench-tools-DATE.tgz` on a machine.

* Run the `fix-interpreter` script to instruct all binaries to use
  provided `ld-linux` interpreter.

* Optionnaly deploy the tools in the `PATH` (ie. `install-tools
  /usr/local/bin/`)


## Adding a new tool


* Create the chroot with `010-build-debian.sh`

* Mount this repo into the chroot into `~build/tools-builder`:

```
mount -o bind,ro /path/to/tools-builder CHROOT/home/build/tools-builder
```

* Enter the chroot: `chroot CHROOT`

* Become `build`: `sudo -u build -i`

* Execute a build script: `./tools-builder/the-script.sh`

After testing, do not forget to unmount the `tools-builder` from the
chroot:

```
umount CHROOT/home/build/tools-builder
```


## Copyright

Copyright (c) 2025 Sébastien Gross

Released under GNU Affero General Public License. See the LICENSE file.

Thanks to Willy Tarreau for the original work.
