# Docker Image to build the CRUX Image

FROM crux:latest
MAINTAINER James Mills, prologic at shortcircuit dot net dot au

# Volumes
VOLUME /mnt/media

# Startup
CMD ["./build.sh"]

# Configuration
ENV URL http://crux.ninja/updated-iso/crux-3.1-updated.iso

RUN mkdir -p /build
COPY . /build/
WORKDIR /build
