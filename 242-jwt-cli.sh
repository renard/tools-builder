#!/bin/bash

set -e
. "$(dirname $0)/env"
cd $SRC

# Cargo build are awfuly long.
# Just retreive the jwt binary version and use it against our libs 
if ! test -f $PREFIX/bin/jwt; then
   curl -L https://github.com/mike-engel/jwt-cli/releases/download/$JWT_CLI_VERSION/jwt-linux.tar.gz | tar -C $PREFIX/bin -xvzf - jwt
fi

