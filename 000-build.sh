#!/bin/bash

# This is the main script that builds tools required to run bnechmarks.
#
# Its main goal is to automate the build.

set -e
. "$(dirname $0)/env"

$(dirname $0)/010-build-debian.sh
$(dirname $0)/011-build-all.sh
