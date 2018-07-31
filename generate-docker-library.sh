#!/usr/bin/env bash

cat <<-EOH
# This file is generated via https://github.com/Silverpeas/docker-silverpeas-prod/blob/master/generate-docker-library.sh
Maintainers: Miguel Moquillon <miguel.moquillon@silverpeas.org> (@mmoqui)
GitRepo: https://github.com/Silverpeas/docker-silverpeas-prod.git
EOH

function printVersion() {
  cat <<-EOE

Tags: $1
GitCommit: $2
	EOE
}

isFirst=1
for version in `git tag | tac | grep "^[0-9.]\+$"`; do
  commit=`git rev-parse ${version}`
  if [ $isFirst -eq 1 ]; then
    isFirst=0
    printVersion "${version}, latest" ${commit}
  else
    printVersion "${version}" ${commit}
  fi
done
