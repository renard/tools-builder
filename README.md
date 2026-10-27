# tools-builder

This repository contains a list of scripts that build relocatable
binaries.

The goal is to have tools to perform benchmarks on different machines
without having to rebuild them for all environments.


## Workflow

* A Debian chroot is created to build all binaries in a sandbox.

* Tools are downloaded from their official git repos and built in the
  sandbox.

* An archive of relocatable binaries is created.


## Prerequisites

The build must run as root on a Debian or Ubuntu host. The following
packages are required:

* `debootstrap` to create the chroot
* `mount` to bind-mount the repository into the chroot (not required
  when building via GitHub Actions, where a copy is used instead)

The chroot creation and all builds are handled automatically by
`000-build.sh`.


## SSL flavors

Many tools are built twice, once against OpenSSL and once against
AWS-LC (a BoringSSL-compatible library maintained by AWS). The
resulting binaries are suffixed accordingly:

```
bin/curl-openssl
bin/curl-aws-lc
bin/haproxy-openssl
bin/haproxy-aws-lc
...
```

The SSL libraries follow the same convention:

```
lib/libssl-openssl.so
lib/libssl-aws-lc.so
lib/libcrypto-openssl.so
lib/libcrypto-aws-lc.so
```

This allows running the same tool against different TLS stacks on the
same machine without any conflict.


## Tools

The version of each entry is substituted from the `env` file by
`update-readme.sh`. Each entry carries the `env` variable to take its
version from in an HTML comment, invisible once rendered:

```
* OpenSSL <!-- OPENSSL_VERSION --> 3.6.5 (https://github.com/openssl/openssl)
```

Branch names such as `master` or `dev` are dropped. Run
`update-readme.sh` each time the `env` file is modified.

* Libs:

  * OpenSSL <!-- OPENSSL_VERSION --> 3.6.5 (https://github.com/openssl/openssl)
  * AWS-LC <!-- AWS_LC_VERSION --> 5.1.0 (https://github.com/aws/aws-lc)
  * HTTP3 support - nghttp3 <!-- NGHTTP3_VERSION --> 1.18.0 (https://github.com/ngtcp2/nghttp3)
  * HTTP2 support - nghttp2 <!-- NGHTTP2_VERSION --> 1.70.0 (https://github.com/nghttp2/nghttp2)
  * QUIC/HTTP3 transport - ngtcp2 <!-- NGTCP2_VERSION --> 1.25.0 (https://github.com/ngtcp2/ngtcp2)
  * libpcap <!-- LIBPCAP_VERSION --> 1.11.0 (https://github.com/the-tcpdump-group/libpcap)
  * patchelf <!-- PATCHELF_VERSION --> 0.19.2 (https://github.com/NixOS/patchelf)

* traffic generator:

  * h1load <!-- H1LOAD_VERSION --> (https://github.com/wtarreau/h1load)
  * h2load <!-- NGTCP2_VERSION --> 1.25.0 (https://github.com/ngtcp2/ngtcp2) with http3 support
  * curl <!-- CURL_VERSION --> 8_22_0 (https://github.com/curl/curl) with http3 support
  * syslog injectors <!-- LOGCNT_VERSION --> (https://github.com/wtarreau/logcnt)
  * inject <!-- INJECT_VERSION --> (https://github.com/wtarreau/inject)

* Proxies

  * HAProxy <!-- HAPROXY_VERSIONS --> 3.2.25 3.3.16 3.4.6 3.5-dev8 (http://git.haproxy.org)
  * HAPEE <!-- HAPEE_VERSIONS --> (http://git.hapee.org)

* Servers:

  * httpterm <!-- HTTPTERM_VERSION --> (https://github.com/wtarreau/httpterm)
  * syslog server <!-- LOGCNT_VERSION --> (https://github.com/wtarreau/logcnt)


* monitoring:

  * if_rate <!-- IFRATE_VERSION --> (https://github.com/wtarreau/if_rate)
  * c2clat <!-- C2CLAT_VERSION --> (https://github.com/rigtorp/c2clat)
  * mhz <!-- MHZ_VERSION --> (https://github.com/wtarreau/mhz)
  * ram latency <!-- RAMSPEED_VERSION --> (https://github.com/wtarreau/ramspeed)
  * mtr <!-- MTR_VERSION --> 0.96 (https://github.com/traviscross/mtr)
  * tcpdump <!-- TCPDUMP_VERSION --> 4.99.7 (https://github.com/the-tcpdump-group/tcpdump)

* other tools

  * nmap <!-- NMAP_VERSION --> (https://github.com/nmap/nmap)
  * rsync <!-- RSYNC_VERSION --> 3.5.1 (https://github.com/RsyncProject/rsync)
  * strace <!-- STRACE_VERSION --> 7.2 (https://github.com/strace/strace)
  * socat <!-- SOCAT_VERSION --> tag-1.8.1.3 (https://repo.or.cz/socat.git, mirror: https://third-party-mirror.googlesource.com/socat/)
  * jq <!-- JQ_VERSION --> 1.8.2 (https://github.com/jqlang/jq)
  * fio <!-- FIO_VERSION --> 3.43 (https://git.kernel.dk/cgit/fio/, mirror: https://github.com/axboe/fio)
  * mandoc <!-- MANDOC_VERSION --> 1.14.6 (https://mandoc.bsd.lv/snapshots). Renamed to `manbt` to prevent from system command clash.
  * 7zip <!-- S_7ZIP_VERSION --> 26.04 (https://github.com/ip7z/7zip)
  * jwt-cli <!-- JWT_CLI_VERSION --> 6.2.0 (https://github.com/mike-engel/jwt-cli/) [1].
  * timewarp <!-- TIMEWARP_VERSION --> (https://github.com/renard/timewarp)
  * fping <!-- FPING_VERSION --> 5.5 (https://github.com/schweikert/fping)


[1] - Cargo takes too long to compile. jwt binary is retrieved from a
pre-built release archive and made ready to use with provided libs for
proper relocation.


## Configuration

Tool versions and build parameters are defined in the `env` file at
the root of the repository. The main variables are:

* `DEBIAN_VERSION` - Debian release used for the chroot (default: bookworm)
* `PREFIX` - installation prefix inside the chroot (default: ~/bench-tools)
* `BUILD_USER` / `BUILD_UID` - user that runs the builds inside the chroot
* `RELEASE` - archive suffix, set to the current date by default, overridden
  by the CI with the git tag name
* Per-tool version variables (e.g. `CURL_VERSION`, `HAPROXY_VERSION`, ...)


## Archive structure

The generated `bench-tools-DATE.tgz` archive has the following layout:

```
bench-tools-DATE/
  bin/          all binaries (suffixed by SSL flavor when applicable)
  lib/          all shared libraries
  man/          man pages
  patchelf      patchelf binary used by fix-interpreter
  fix-interpreter   script to update ELF interpreter paths
  install-tools     script to create symlinks in a target directory
```


## Howto

* Deploy this repository on a Debian Linux host and run the
  `000-build.sh` script as root.

* A `bench-tools-DATE.tgz` archive is generated.

* Copy and unarchive the `bench-tools-DATE.tgz` on the target machine.

* Run `fix-interpreter` to update the ELF interpreter path of all
  binaries to use the `ld-linux` provided in the archive:

```
./fix-interpreter
```

`fix-interpreter` must be re-run each time the archive is moved to a
different location on the filesystem, as interpreter paths are
absolute.

If run as root, `fix-interpreter` also sets the required Linux
capabilities on HAProxy binaries (`cap_net_bind_service`,
`cap_net_raw`), which allows it to bind privileged ports and use
transparent proxy without running as root.

* Optionally deploy the tools in the `PATH` (ie. `install-tools
  /usr/local/bin/`)

`install-tools` creates symlinks in the target directory pointing to
the binaries in `bin/`. If no argument is given it defaults to the
current directory.


## How relocation works

A standard dynamically linked ELF binary depends on two things baked
into the binary at build time:

* The ELF interpreter, usually a hardcoded absolute path such as
  `/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2`. This is the dynamic
  linker that the kernel hands control to before running the binary.
  If that path does not exist on the target machine (different distro,
  different libc version), the binary refuses to start.

* The RPATH, a list of directories where the dynamic linker looks for
  shared libraries. Without an RPATH the linker falls back to system
  paths (`/lib`, `/usr/lib`, ...), picking up whatever version happens
  to be installed.

Both of these make binaries non-portable by default.

### $ORIGIN

The dynamic linker supports the special token `$ORIGIN` in RPATH
entries. At runtime it expands to the directory containing the binary
(or the library) being loaded. This makes it possible to express
relative paths:

* Binaries use `$ORIGIN/../lib` as their RPATH: the linker looks for
  libraries in the `lib/` directory next to `bin/`.

* Libraries use `$ORIGIN` as their RPATH: the linker looks for
  dependencies in the same directory as the library itself.

Since these paths are relative to the location of the file, the whole
archive can be placed anywhere on the filesystem and libraries will
always be found.

### patchelf

patchelf is used at build time to rewrite the metadata of each binary
and library:

* `--set-interpreter` replaces the hardcoded system interpreter path
  with the path to the `ld-linux` bundled in the archive.

* `--set-rpath` sets the `$ORIGIN`-based RPATH described above.

* `--replace-needed` rewrites a specific library dependency name in
  the binary's import table. This is how SSL flavor suffixes are
  applied: for example `libssl.so` is rewritten to `libssl-openssl.so`
  or `libssl-aws-lc.so` depending on which flavor was built.

* `--set-soname` rewrites the SONAME embedded in a shared library.
  When a library is renamed on disk its SONAME must match, otherwise
  the dynamic linker will refuse to load it.

patchelf itself is built as a static binary so it has no external
dependencies and can be shipped in the archive root for use by
`fix-interpreter`.

### fix-interpreter

At build time the interpreter path written into the binaries is the
absolute path inside the chroot. Once the archive is extracted on a
target machine that path is wrong.

`fix-interpreter` uses the bundled `patchelf` to rewrite the
interpreter path of every binary to the absolute path of the
`ld-linux` found in the archive's `lib/` directory. It also resets
the RPATH to `$ORIGIN/../lib` in case it was altered.

Because the new interpreter path is absolute, `fix-interpreter` must
be re-run whenever the archive is moved on the filesystem.

### Special case: HAProxy and Linux capabilities

When Linux capabilities are set on a binary (`cap_net_bind_service`,
`cap_net_raw`), the dynamic linker operates in secure mode and ignores
`$ORIGIN` in RPATH for security reasons (see ld.so(8)). An
`$ORIGIN`-based RPATH would therefore cause HAProxy to fail to load
its libraries.

For this reason, when `fix-interpreter` is run as root it replaces the
`$ORIGIN/../lib` RPATH of HAProxy binaries with the absolute path to
the `lib/` directory, then sets the capabilities. This makes HAProxy
binaries non-relocatable: if the archive is moved, `fix-interpreter`
must be re-run as root to update both the absolute RPATH and the
capabilities.


## CI/CD

A GitHub Actions workflow builds and publishes a release automatically
when a tag is pushed:

```
git tag v1.0.0
git push origin v1.0.0
```

The workflow creates a Debian chroot, runs all build scripts, and
uploads the resulting `bench-tools-TAG.tgz` as a GitHub release
artifact.

The workflow can also be triggered manually from the GitHub Actions UI
via `workflow_dispatch`.


## Adding a new tool

* Add the `TOOL_VERSION` variable to the `env` file and a tools list
  entry to `README.md` with a `<!-- TOOL_VERSION -->` marker, then
  run `update-readme.sh`.

* Create the chroot with `010-build-debian.sh`

* Mount this repo into the chroot into `~runner/tools-builder`:

```
mount -o bind,ro /path/to/tools-builder CHROOT/home/runner/tools-builder
```

* Enter the chroot: `chroot CHROOT`

* Become `runner`: `sudo -u runner -i`

* Execute a build script: `./tools-builder/the-script.sh`

After testing, do not forget to unmount the `tools-builder` from the
chroot:

```
umount CHROOT/home/runner/tools-builder
```


## Copyright

Copyright (c) 2025 Sébastien Gross

Released under GNU Affero General Public License. See the LICENSE file.

Thanks to Willy Tarreau for the original work.
