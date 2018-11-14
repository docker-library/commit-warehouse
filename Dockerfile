FROM scratch
MAINTAINER James Mills, prologic at shortcircuit dot net dot au
ADD rootfs.tar.xz /
CMD ["/bin/bash"]
