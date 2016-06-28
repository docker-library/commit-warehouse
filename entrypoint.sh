#!/bin/sh
set -eu

if ! command -v -- "$1" >/dev/null 2>&1
then
  java \
    -Djava.io.tmpdir="$RAPIDOID_TMP" \
    -cp "$RAPIDOID_JAR:/app/app.jar:/app/*.jar" \
    org.rapidoid.standalone.Main \
    app.jar=/app/app.jar \
    root=/app \
    "$@"
else
  exec "$@"
fi
