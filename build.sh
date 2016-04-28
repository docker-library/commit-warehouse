#!/usr/bin/env bash

if [ $# -eq 2 ]; then
  silverpeas_version=$1
  wildfly_version=$2

  docker build \
    --build-arg SILVERPEAS_VERSION=$silverpeas_version \
    --build-arg WILDFLY_VERSION=$wildfly_version \
    -t silverpeas:$silverpeas_version \
    .
else
  docker build \
    -t silverpeas:latest \
    .
fi
