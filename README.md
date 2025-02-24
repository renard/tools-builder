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

  * AWS-LC

* taffic generator:

  * h1load
  * h2load with http3 support
  * curl with http3 support
  * syslog injectors
  * inject

* Servers:

  * httpterm
  * syslog server


* monitoring:

  * if_rate
  * c2clat
  * mhz
  * ram latency
  * tcpdump

* other tools

  * nmap
  * strace
  * socat

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
