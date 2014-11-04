#!/usr/bin/env bash

set -e

die () {
    echo >&2 "$@"
    exit 1
}

[ "$#" -eq 3 ] || die "3 argument(s) required, $# provided. Usage: ./package.sh /path/to/rootfs tag version"

ROOTFS=${1}
TAG=${2}
VERSION=${3}

tar --numeric-owner --exclude=/etc/mtab --exclude=/root/.bash_history \
    -P -cJvf rootfs.tar.xz -C $ROOTFS ./

if $(which docker &> /dev/null); then
    ID=$(tar --numeric-owner -C $ROOTFS -c . | docker import - ${TAG}:$VERSION)
    docker tag $ID ${TAG}:latest
    docker run -i -t crux echo Success.
fi
