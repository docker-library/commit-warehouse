#!/usr/bin/env bash

set -e

die () {
    echo >&2 "$@"
    exit 1
}

[ "$#" -eq 1 ] || die "1 argument(s) required, $# provided. Usage: ./cleanup.sh /path/to/rootfs"

ROOTFS=${1}

# Remove agetty and inittab config
if (grep agetty ${ROOTFS}/etc/inittab 2>&1 > /dev/null); then
    echo "Removing agetty from /etc/inittab ..."
    chroot ${ROOTFS} sed -i -e "/agetty/d" /etc/inittab
    chroot ${ROOTFS} sed -i -e "/shutdown/d" /etc/inittab
    chroot ${ROOTFS} sed -i -e "/^$/N;/^\n$/d" /etc/inittab
fi

# Remove kernel source
rm -rf $ROOTFS/usr/src/*

# Remove unnecessary packages
pkgs=(btrfs-progs dhcpcd e2fsprogs ed exim hdparm jfsutils libusb-compat kbd lilo man-db man-pages mlocate openssh pciutils ppp psmisc rc reiserfsprogs sysfsutils sysvinit xfsprogs)

for pkg in ${pkgs[@]}; do
    chroot ${1} /usr/bin/pkgrm $pkg || true
done
