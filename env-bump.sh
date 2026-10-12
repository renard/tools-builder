#!/bin/bash

# env-bump --- List the version bumps of the env file since a git commit.

### BEGIN HELP
# env-bump --- List the version bumps of the env file since a git commit.
#
# env-bump Version 0.2.0
#
# Copyright © 2026 Sébastien Gross
#
# Usage:
#
#    env-bump [ GIT_REF ]
#
# Options:
#
#   -h|--help           This help screen.
#
# Arguments:
#
#   GIT_REF             Revision to compare the working env file with.
#                       Defaults to HEAD.
#
# Only *_VERSION and *_VERSIONS variables are reported. The tool name is
# the variable name stripped from its suffix, lowercased, with its
# underscores replaced by dashes.
#
# Examples:
#
#    env-bump                       working env against HEAD
#    env-bump HEAD~3                working env against HEAD~3
#
# Output:
#
#   - ngtcp2: v1.22.0 -> v1.25.0
### END HELP

dir=$(cd "$(dirname "$0")" && pwd)
env_file=$dir/env
env_rel="$(git -C "$dir" rev-parse --show-prefix)env"


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


# Print one line per version variable whose value differs between two
# env files. Variables missing from one of the files are ignored: this
# tools reports bumps, not additions or removals.
# Input: old env file, new env file. Output: "- tool: old -> new" lines.
report() {
	awk -v old="$1" -v new="$2" '
	# Index the version variables of an env file into dest, an array
	# passed by reference. Values are taken from the first "=" up to
	# the end of line so that array values such as (v1 v2) survive.
	function load(path, dest,    line, name) {
		while ((getline line < path) > 0) {
			if (line !~ /^[A-Z0-9_]+VERSIONS?=/)
				continue
			split(line, parts, "=")
			name = parts[1]
			dest[name] = substr(line, length(name) + 2)
		}
		close(path)
	}

	# Turn a variable name into a tool name.
	function tool(name) {
		sub(/_VERSIONS?$/, "", name)
		name = tolower(name)
		gsub(/_/, "-", name)
		return name
	}

	BEGIN {
		load(old, prev)
		load(new, cur)
		for (name in prev)
			if (name in cur && cur[name] != prev[name])
				printf "- %s: %s -> %s\n", tool(name), \
					prev[name], cur[name]
	}
	' </dev/null
}


case "${1:-}" in
-h|--help) usage 0 ;;
esac
test $# -gt 1 && usage
ref=${1:-HEAD}

test -f "$env_file" || die "env file not found: $env_file."
git -C "$dir" rev-parse --verify --quiet "$ref^{commit}" >/dev/null \
	|| die "unknown revision: $ref."

report <(git -C "$dir" show "$ref:$env_rel") "$env_file" | sort
