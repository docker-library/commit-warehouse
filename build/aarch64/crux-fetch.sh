#fetching aarch64 rootfs
VERSION=$1
wget http://resources.crux-arm.nu/releases/${VERSION}/crux-arm-rootfs-${VERSION}-aarch64.tar.xz -O $(dirname "$0")/rootfs.tar.xz
