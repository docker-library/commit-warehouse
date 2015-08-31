#!/bin/bash

set -e

url=${1:-http://ftp.morpheus.net/pub/linux/crux/latest/iso/crux-3.1.iso}

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

git branch ${version} origin/dist
git checkout ${version}

docker cp cruxbuild:/rootfs.tar.xz .
docker rm -f cruxbuild

git add rootfs.tar.xz
git commit -m "${version}"

docker build -t crux:${version} .
