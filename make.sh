#!/bin/bash

set -e

url=${1:-http://ftp.morpheus.net/pub/linux/crux/latest/iso/crux-3.1.iso}
version=$(basename --suffix=.iso $url | sed 's/[^0-9.]*\([0-9.]*\).*/\1/')

docker build -t cruxbuild build

docker rm -f cruxbuild

docker run \
	-i -t --privileged \
	--name cruxbuild \
	-e URL=${url} \
	-v $(pwd)/media:/mnt/media \
	cruxbuild

if $(git show-ref --verify --quiet refs/heads/${version}); then
	git branch -D ${version}
fi

git checkout -b ${version} origin/dist

docker cp cruxbuild:/build/rootfs.tar.xz .
docker rm -f cruxbuild

git add rootfs.tar.xz
git commit -m "${version}"

docker build -t crux:${version} .
