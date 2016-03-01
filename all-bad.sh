#!/bin/bash
set -e

cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

bashbrew list --all \
	| cut -d: -f1 \
	| sort -u \
	| sed 's!^!https://raw.githubusercontent.com/docker-library/official-images/master/library/!' \
	| xargs ./bad.sh
