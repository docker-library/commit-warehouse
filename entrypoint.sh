#!/bin/sh
set -e

if ! command -v -- "$1" >/dev/null 2>&1
then

  if [ -f /app/app.jar ]
  then
    JAR='/app/app.jar'
  else
    JAR="$RAPIDOID_JAR"
  fi

  set -- java \
    -Djava.io.tmpdir="$RAPIDOID_TMP" \
    -XX:+UnlockExperimentalVMOptions \
    -XX:+UseCGroupMemoryLimitForHeap \
    -jar "$JAR" \
    "$@"
fi

exec "$@"
