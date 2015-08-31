# Docker Image to build the CRUX Image

FROM crux:latest
MAINTAINER James Mills, prologic at shortcircuit dot net dot au

# Volumes
VOLUME /mnt/media

# Startup
CMD ["./build.sh"]

RUN mkdir -p /build
COPY . /build/
WORKDIR /build
