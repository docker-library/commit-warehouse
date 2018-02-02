#!/usr/bin/env bash

cat <<-EOH
# This file is generated via https://github.com/Silverpeas/docker-silverpeas-prod/blob/master/generate-docker-library.sh
Maintainers: Miguel Moquillon <miguel.moquillon@silverpeas.org> (@mmoqui)
GitRepo: https://github.com/Silverpeas/docker-silverpeas-prod.git
EOH

for version in `git tag | tac | grep "^[0-9.]\+$"`; do
  commit=`git rev-parse ${version}`
  cat <<-EOE

Tags: ${version}
GitCommit: ${commit}
	EOE
done