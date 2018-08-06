FROM ubuntu:16.04 as builder

# install packages
RUN apt-get update \
  && apt-get install -y curl \
  && rm -rf /var/lib/apt/lists/*

# grab gosu
RUN gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
  && curl -fsSL "https://github.com/tianon/gosu/releases/download/1.10/gosu-$(dpkg --print-architecture)" -o /tmp/gosu \
  && curl -fsSL "https://github.com/tianon/gosu/releases/download/1.10/gosu-$(dpkg --print-architecture).asc" -o /tmp/gosu.asc \
  && gpg --batch --verify /tmp/gosu.asc /tmp/gosu \
  && chmod +x /tmp/gosu

# use --build-arg key=value in docker build command to override arguments
ARG BONITA_VERSION
ARG TOMCAT_VERSION
ARG BONITA_SHA256
ARG BASE_URL
ARG BONITA_DBTOOL_SHA256
ARG BONITA_DBTOOL_URL

ENV BONITA_VERSION ${BONITA_VERSION:-7.5.4}
ENV TOMCAT_VERSION ${TOMCAT_VERSION:-7.0.76}
ENV BASE_URL ${BASE_URL:-http://repositories.rd.lan/nas/releases/bonita_platform/7.x/7.5.x/${BONITA_VERSION}/BonitaBPMSubscription-${BONITA_VERSION}/}
ENV BONITA_URL ${BASE_URL}/BonitaBPMSubscription-${BONITA_VERSION}-Tomcat-${TOMCAT_VERSION}.zip
ENV BONITA_SHA256  ${BONITA_SHA256:-404b812bbd391920465bc305e62941615e9abea20c2ad1bec4f7389ff75a9bf9}
ENV BONITA_DBTOOL_VERSION 7.0.0-07
ENV BONITA_DBTOOL_SHA256 ${BONITA_DBTOOL_SHA256:-ab285b1babd64ab5e65e1cff976d009a2ed3b4a686079c65843ef26c382bd23f}
ENV BONITA_DBTOOL bonita-deployer-${BONITA_DBTOOL_VERSION}-databases
ENV BONITA_DBTOOL_URL ${BONITA_DBTOOL_URL:-http://repositories.rd.lan/archiva/repository/releases/org/bonitasoft/tools/bonita-deployer/${BONITA_DBTOOL_VERSION}}

# create destination folder for downloads
RUN mkdir /opt/custom-init.d/ \
  && mkdir /opt/files

# retrieve bonita deployer databases tool
RUN curl -fsSL ${BONITA_DBTOOL_URL}/${BONITA_DBTOOL}.zip -o /opt/files/${BONITA_DBTOOL}.zip \
  && echo "$BONITA_DBTOOL_SHA256" /opt/files/${BONITA_DBTOOL}.zip | sha256sum -c -

COPY files /opt/files
COPY templates /opt/templates

# add Bonita BPM archive to the container
RUN curl -fsSL ${BONITA_URL} -o /opt/files/BonitaBPMSubscription-${BONITA_VERSION}-Tomcat-${TOMCAT_VERSION}.zip \
  && sha256sum /opt/files/BonitaBPMSubscription-${BONITA_VERSION}-Tomcat-${TOMCAT_VERSION}.zip \
  && echo "$BONITA_SHA256" /opt/files/BonitaBPMSubscription-${BONITA_VERSION}-Tomcat-${TOMCAT_VERSION}.zip | sha256sum -c -



FROM ubuntu:16.04

LABEL authors="Jérémy Jacquier-Roux <jeremy.jacquier-roux@bonitasoft.com>, Truc Nguyen <truc.nguyen@bonitasoft.com>"

# install packages
RUN apt-get update && apt-get install -y \
  mysql-client-core-5.7 \
  openjdk-8-jre-headless \
  postgresql-client \
  unzip \
  curl \
  zip \
  ant \
  && rm -rf /var/lib/apt/lists/*

ARG BONITA_VERSION
ARG TOMCAT_VERSION
ENV BONITA_VERSION ${BONITA_VERSION:-7.5.4}
ENV TOMCAT_VERSION ${TOMCAT_VERSION:-7.0.76}
ENV BONITA_DBTOOL_VERSION 7.0.0-07
ENV BONITA_DBTOOL bonita-deployer-${BONITA_DBTOOL_VERSION}-databases

COPY --from=builder /opt /opt
COPY --from=builder /tmp/gosu /usr/local/bin/gosu

# create user to launch Bonita as non-root
RUN groupadd -r bonita -g 1000 \
  && useradd -u 1000 -r -g bonita -d /opt/bonita/ -s /sbin/nologin -c "Bonita User" bonita

# volumes
VOLUME ["/opt/bonita", "/opt/bonita_lic"]

# exposed ports (Tomcat, Hazelcast)
EXPOSE 8080 5701

# command to run when the container starts
CMD ["/opt/files/startup.sh"]
