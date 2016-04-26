#!/usr/bin/env bash

die() {
  echo "Missing arguments: the Silverpeas version and/or the Wildfly version"
  exit 1
}

test $# -eq 2 || die

silverpeas_version=$1
wildfly_version=$2

docker build \
  --build-arg SILVERPEAS_VERSION=$silverpeas_version \
  --build-arg WILDFLY_VERSION=$wildfly_version \
  -t silverpeas-prod-$silverpeas_version \
  .
