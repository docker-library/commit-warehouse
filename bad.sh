#!/usr/bin/env bash
set -Eeuo pipefail

template="$(dirname "$(readlink -f "$BASH_SOURCE")")/bad.sh.tmpl"

export BASHBREW_CACHE="${BASHBREW_CACHE:-${XDG_CACHE_HOME:-$HOME/.cache}/bashbrew}"
cd "$BASHBREW_CACHE/git"

set -- $(
	bashbrew list "$@" \
		| sed 's!^!https://github.com/docker-library/official-images/raw/master/library/!'
)

arches=( $(
	bashbrew cat --format '
		{{- range .Entries -}}
			{{- range .Architectures -}}
				{{- . -}}{{- "\n" -}}
			{{- end -}}
		{{- end -}}
	' "$@" \
		| sort -u
) )

for arch in "${arches[@]}"; do
	bashbrew --arch="$arch" cat -F "$template" "$@" \
		| grep -vE '[.]git$' \
		| bash -Eeuo pipefail -x
done
