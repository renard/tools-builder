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

## How to build

Deploy this repository on a Debian Linux host and run the
`000-build.sh` script.


## Copyright

Copyright (c) 2025 Sébastien Gross

Released under GNU Affero General Public License. See the LICENSE file.

Thanks to Willy Tarreau for the original work.
