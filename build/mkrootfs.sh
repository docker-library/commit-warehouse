#!/usr/bin/env bash
# Generate a minimal filesystem for CRUX/Linux and load it into the local
# docker as "crux". Requires root and the crux iso (http://crux.nu)
#
# Usage: ./mkrootfs.sh /path/to/crux/iso

set -e

die () {
    echo >&2 "$@"
    exit 1
}

[ "$#" -eq 1 ] || die "1 argument(s) required, $# provided. Usage: ./mkimage-crux.sh /path/to/crux/iso"

ISO=${1}

ROOTFS=$(mktemp -d /tmp/rootfs-XXXXXXXXXX)
CRUX=$(mktemp -d /tmp/crux-XXXXXXXXXX)
TMP=$(mktemp -d /tmp/XXXXXXXXXX)

VERSION=$(basename --suffix=.iso $ISO | sed 's/[^0-9.]*\([0-9.]*\).*/\1/')

# Ensure $ROOTFS directory exists
if [ ! -d $ROOTFS ]; then
    mkdir -p $ROOTFS
fi

# Mount the ISO
mount -o ro,loop $ISO $CRUX

# Extract pkgutils
tar -C $TMP -xf $CRUX/tools/pkgutils#*.pkg.tar.gz

# Put pkgadd in the $PATH
export PATH="$TMP/usr/bin:$PATH"

# Install core packages
mkdir -p $ROOTFS/var/lib/pkg
touch $ROOTFS/var/lib/pkg/db
for pkg in $CRUX/crux/core/*; do
    pkgadd -r $ROOTFS $pkg
done

./cleanup.sh $ROOTFS
./mkdev.sh $ROOTFS
./package.sh $ROOTFS

# Cleanup
umount $CRUX
rm -rf $ROOTFS
rm -rf $CRUX
rm -rf $TMP
