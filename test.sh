#!/bin/bash

set -e

dpkgArch="$(uname -m)";
	case "${dpkgArch##*-}" in
	x86_64)
		version=${1:-3.4}

		docker build -t cruxbuild build

		docker run \
			-i -t --privileged \
			--name cruxbuild \
			-e VERSION=${version} \
			-v $(pwd)/media:/mnt/media \
			cruxbuild

		docker cp cruxbuild:/rootfs.tar.xz .
		docker import - test < rootfs.tar.xz
		docker rm -f cruxbuild;;

	aarch64)
		$sh aarch64/crux-fetch.sh
		$(mv crux-arm-rootfs-3.4-aarch64.tar.xz aarch64/)

		docker build -t cruxbuild aarch64;;
	esac;
