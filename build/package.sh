#!/usr/bin/env bash

set -e

die () {
    echo >&2 "$@"
    exit 1
}

[ "$#" -eq 1 ] || die "1 argument(s) required, $# provided. Usage: ./package.sh /path/to/rootfs"

ROOTFS=${1}

echo "Packaging Root FS ..."

tar --numeric-owner \
    --exclude=/etc/mtab \
    --exclude=/root/.bash_history \
    -P -cJf rootfs.tar.xz \
    -C $ROOTFS ./
