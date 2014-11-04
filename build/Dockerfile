# Docker Image to build the CRUX Image

FROM crux:latest
MAINTAINER James Mills, prologic at shortcircuit dot net dot au

# Volumes
VOLUME /mnt/media

# Startup
CMD ["./build.sh"]

# Configuration
ENV NAME crux
ENV VERSION 3.1
ENV URL http://ftp.morpheus.net/pub/linux/crux
ENV MEDIA /mnt/media

ADD . /
