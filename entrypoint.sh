#!/bin/sh
set -e

if ! command -v -- "$1" >/dev/null 2>&1
then
  set -- java \
    -Djava.io.tmpdir="$RAPIDOID_TMP" \
    -jar "$RAPIDOID_JAR" \
    "$@"
fi

exec "$@"
