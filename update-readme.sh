#!/bin/bash

# update-readme --- Update the tool versions of README.md from env.

### BEGIN HELP
# update-readme --- Update the tool versions of README.md from env.
#
# update-readme Version 0.1.0
#
# Copyright © 2026 Sébastien Gross
#
# Usage:
#
#    update-readme [ -h ]
#
# Options:
#
#   -h|--help           This help screen.
#
# Each entry of the tools list of README.md carries the env variable
# to take its version from in an HTML comment, invisible once
# rendered:
#
#    * OpenSSL <!-- OPENSSL_VERSION --> 3.6.5 (https://...)
#
# The text between the comment and the url is replaced by the
# variable value. A leading tool name prefix and v are stripped from
# each element. Branch names such as master or dev are dropped.
# Array values are joined with a space. Run this script each time
# the env file is modified.
### END HELP

dir=$(cd "$(dirname "$0")" && pwd)
readme=$dir/README.md
env_file=$dir/env


# Print the embedded help screen and exit.
# Input: optional exit status. Output: the help text on stdout.
usage() {
	exit_code=${1:-1}
	sed -e '1,/^### BEGIN HELP/d;/^### END HELP/,$d;s/^#\{1,\} \{0,1\}//' $0
	exit ${exit_code}
}


# Print an error message on stderr and leave with a failure status.
# Input: the message. Output: none.
die() {
	echo "$0: $*" >&2
	exit 1
}


case "${1:-}" in
-h|--help) usage 0 ;;
esac
test $# -gt 1 && usage

test -f "$readme" || die "README.md not found: $readme."
test -f "$env_file" || die "env file not found: $env_file."

awk -v env_file="$env_file" '
# Index the version variables of the env file into ver. Values are
# taken from the first "=" up to the end of line so that array values
# such as (v1 v2) survive, without their wrapping parenthesis.
function load(path,    line, n, name, val) {
	while ((getline line < path) > 0) {
		if (line !~ /^[A-Z0-9_]+_VERSIONS?=/)
			continue
		n = index(line, "=")
		name = substr(line, 1, n - 1)
		val = substr(line, n + 1)
		sub(/^\(/, "", val)
		sub(/\)[ \t]*$/, "", val)
		ver[name] = val
	}
	close(path)
}

# Rewrite the version of a tools list entry of README.md. Branch
# names are dropped, the tool name prefix and a leading v are
# stripped from each element of the value.
# Input: the line. Output: the updated line on stdout.
function rewrite(line,    marker, var, slug, val, els, n, i, el,
		head, tail, pos, rest, sep) {
	if (line !~ /^ *\* / || !match(line, /<!-- [A-Z0-9_]+_VERSIONS? -->/)) {
		print line
		return
	}
	marker = substr(line, RSTART, RLENGTH)
	var = marker
	gsub(/[^A-Z0-9_]/, "", var)
	if (!(var in ver))
		printf "update-readme: unknown env variable: %s\n", \
			var > "/dev/stderr"
	slug = tolower(var)
	sub(/_versions?$/, "", slug)
	gsub(/_/, "-", slug)

	val = ""
	n = split(ver[var], els, /[ \t]+/)
	for (i = 1; i <= n; i++) {
		el = els[i]
		if (el == "" || el == "master" || el == "dev")
			continue
		sub("^" slug "-", "", el)
		if (el ~ /^v[0-9]/)
			sub(/^v/, "", el)
		val = val (val == "" ? "" : " ") el
	}

	head = substr(line, 1, RSTART - 1)
	tail = substr(line, RSTART + RLENGTH)
	pos = index(tail, "(")
	if (pos == 0) {
		printf "update-readme: no url on line: %s\n", line \
			> "/dev/stderr"
		print line
		return
	}
	rest = substr(tail, pos)
	sep = (val == "" ? "" : " ")
	printf "%s%s%s%s\n", head, marker, sep val, " " rest
}

BEGIN {
	load(env_file)
}

{ rewrite($0) }
' "$readme" > "$readme.new" || die "awk failed."
mv "$readme.new" "$readme"