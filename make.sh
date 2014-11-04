#!/bin/bash

set -e

version=${1:-3.1}

docker build -t cruxbuild build

docker run \
	-i -t --privileged \
	--name cruxbuild \
	-e VERSION=${version} \
	-v $(pwd)/media:/mnt/media \
	cruxbuild

git branch -D 3.1
git branch 3.1 origin/dist
git checkout 3.1

docker cp cruxbuild:/rootfs.tar.xz .
docker rm -f cruxbuild

git add rootfs.tar.xz
git commit -m "${version}"

docker build -t crux:${version} .
