#!/bin/bash
set -e

LATEST_VERSION="$(
	git ls-remote --tags https://github.com/rapidoid/rapidoid.git \
		| cut -d/ -f3 \
		| grep -vE -- 'rapidoid-|\^' \
		| sort -V \
		| tail -1
)"

set -x
sed -ri 's/^(ENV RAPIDOID_VERSION) .*/\1 '"$LATEST_VERSION"'/' Dockerfile
