#!/usr/bin/env bash
set -Eeuo pipefail

cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

bashbrew list --repos --all \
	| sed 's!^!https://github.com/docker-library/official-images/raw/master/library/!' \
	| xargs -rtn1 -P "$(nproc)" ./push.sh
