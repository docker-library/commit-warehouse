#!/usr/bin/env bash
set -Eeuo pipefail

template="$(dirname "$(readlink -f "$BASH_SOURCE")")/push.sh.tmpl"

export BASHBREW_CACHE="${BASHBREW_CACHE:-${XDG_CACHE_HOME:-$HOME/.cache}/bashbrew}"
cd "$BASHBREW_CACHE/git"

set -- $(
	bashbrew list --repos "$@" \
		| sed 's!^!https://github.com/docker-library/official-images/raw/master/library/!'
)

bashbrew cat -F "$template" "$@" \
	| grep -vE '[.]git$' \
	| bash -Eeuo pipefail -x
