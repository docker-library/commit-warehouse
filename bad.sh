#!/bin/bash
set -eo pipefail

template="$(dirname "$(readlink -f "$BASH_SOURCE")")/bad.sh.tmpl"

export BASHBREW_CACHE="${BASHBREW_CACHE:-${XDG_CACHE_HOME:-$HOME/.cache}/bashbrew}"
cd "$BASHBREW_CACHE/git"

bashbrew list --repos "$@" \
	| sed 's!^!https://github.com/docker-library/official-images/raw/master/library/!' \
	| xargs bashbrew cat -F "$template" \
	| bash -ex
