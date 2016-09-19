#!/bin/sh
set -e

if ! command -v -- "$1" >/dev/null 2>&1
then
  java \
    -Djava.io.tmpdir="$RAPIDOID_TMP" \
    -cp /app/app.jar \
    -jar "$RAPIDOID_JAR" \
    "$@"
else
  exec "$@"
fi
