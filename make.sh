#!/bin/bash

version=${1:-3.1}


docker build -t cruxbuild build

docker run \
	-i -t --privileged \
	--name cruxbuild \
	-e VERSION=${version} \
	-v $(pwd)/media:/mnt/media \
	cruxbuild

hg update -C dist
docker cp cruxbuild:/rootfs.tar.xz .
docker rm -f cruxbuild

dist=$(hg id -i -r dist)
hg commit -A -m "${version}"
hg bookmark -f ${version}
hg bookmark -f -r ${dist} dist

docker build -t crux:${version} .
