FROM ubuntu:16.04 as base

# common variables
ARG BONITA_VERSION
ARG TOMCAT_VERSION
ENV BONITA_VERSION ${BONITA_VERSION:-7.8.0}
ENV TOMCAT_VERSION ${TOMCAT_VERSION:-8.5.34}
ENV BONITA_DBTOOL_VERSION 7.0.0-07
ENV BONITA_DBTOOL bonita-deployer-${BONITA_DBTOOL_VERSION}-databases

# install packages
RUN apt-get update && apt-get install -y curl \
  && rm -rf /var/lib/apt/lists/*



FROM base as builder

# grab gosu
RUN gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
  && curl -fsSL "https://github.com/tianon/gosu/releases/download/1.10/gosu-$(dpkg --print-architecture)" -o /tmp/gosu \
  && curl -fsSL "https://github.com/tianon/gosu/releases/download/1.10/gosu-$(dpkg --print-architecture).asc" -o /tmp/gosu.asc \
  && gpg --batch --verify /tmp/gosu.asc /tmp/gosu \
  && chmod +x /tmp/gosu

# create destination folder for downloads
RUN mkdir /opt/custom-init.d/ \
  && mkdir /opt/custom-config.d/ \
  && mkdir /opt/files

COPY files /opt/files
COPY templates /opt/templates

# install license module
COPY --from=bonitasoft/bonita-license:latest /bonita-license /bonita-license

RUN apt-get update && apt-get -y install build-essential libxslt-dev python python-dev python-setuptools \
  && easy_install -U pip==9.0.3 \
  && pip install /bonita-license

# use --build-arg key=value in docker build command to override arguments
ARG BONITA_SHA256
ARG BASE_URL
ARG BONITA_DBTOOL_SHA256
ARG BONITA_DBTOOL_URL

ENV BASE_URL ${BASE_URL:-http://repositories.rd.lan/nas/releases/bonita_platform/7.x/7.8.x/${BONITA_VERSION}/BonitaSubscription-${BONITA_VERSION}/}
ENV BONITA_URL ${BASE_URL}/BonitaSubscription-${BONITA_VERSION}-Tomcat-${TOMCAT_VERSION}.zip
ENV BONITA_SHA256  ${BONITA_SHA256:-99d8e0490aeb15a22ff56a6f2e4b6d4429609c554cd4ea619bfa0b1ff25b8b03}
ENV BONITA_DBTOOL_SHA256 ${BONITA_DBTOOL_SHA256:-ab285b1babd64ab5e65e1cff976d009a2ed3b4a686079c65843ef26c382bd23f}
ENV BONITA_DBTOOL_URL ${BONITA_DBTOOL_URL:-http://repositories.rd.lan/archiva/repository/releases/org/bonitasoft/tools/bonita-deployer/${BONITA_DBTOOL_VERSION}}

# retrieve bonita deployer databases tool
RUN curl -fsSL ${BONITA_DBTOOL_URL}/${BONITA_DBTOOL}.zip -o /opt/files/${BONITA_DBTOOL}.zip \
  && echo "$BONITA_DBTOOL_SHA256" /opt/files/${BONITA_DBTOOL}.zip | sha256sum -c -

# add Bonita archive to the container
RUN curl -fsSL ${BONITA_URL} -o /opt/files/BonitaSubscription-${BONITA_VERSION}-Tomcat-${TOMCAT_VERSION}.zip \
  && sha256sum /opt/files/BonitaSubscription-${BONITA_VERSION}-Tomcat-${TOMCAT_VERSION}.zip \
  && echo "$BONITA_SHA256" /opt/files/BonitaSubscription-${BONITA_VERSION}-Tomcat-${TOMCAT_VERSION}.zip | sha256sum -c -



FROM base

LABEL authors="Jérémy Jacquier-Roux <jeremy.jacquier-roux@bonitasoft.com>, Truc Nguyen <truc.nguyen@bonitasoft.com>"

# install packages
RUN apt-get update && apt-get install -y \
  mysql-client-core-5.7 \
  openjdk-8-jre-headless \
  postgresql-client \
  unzip \
  zip \
  ant \
  python \
  cron \
  && rm -rf /var/lib/apt/lists/*

COPY --from=builder /opt /opt
COPY --from=builder /tmp/gosu /usr/local/bin/gosu

COPY --from=builder /usr/local/lib/python2.7/dist-packages /usr/local/lib/python2.7/dist-packages

# volumes
VOLUME ["/opt/bonita", "/opt/bonita_lic"]

# create user to launch Bonita as non-root
RUN groupadd -r bonita -g 1000 \
  && useradd -u 1000 -r -g bonita -d /opt/bonita/ -s /sbin/nologin -c "Bonita User" bonita \
  && touch /opt/bonita/cron.log

# exposed ports (Tomcat, Hazelcast)
EXPOSE 8080 5701

# command to run when the container starts
CMD ["/opt/files/startup.sh"]


HEALTHCHECK --interval=10s --start-period=5m --retries=18 CMD ["/opt/files/healthcheck.sh"]
