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

docker cp cruxbuild:/rootfs.tar.xz .
docker import - test < rootfs.tar.xz
docker rm -f cruxbuild
