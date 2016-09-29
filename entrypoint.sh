#!/bin/sh
set -e

if ! command -v -- "$1" >/dev/null 2>&1
then
  java \
    -Djava.io.tmpdir="$RAPIDOID_TMP" \
    -cp "$RAPIDOID_JAR":/app/app.jar:/app/jars/*.jar org.rapidoid.standalone.Main \
    "$@"
else
  exec "$@"
fi
