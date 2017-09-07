FROM ubuntu:16.04

MAINTAINER Jérémy Jacquier-Roux <jeremy.jacquier-roux@bonitasoft.com>

# install packages
RUN apt-get update && apt-get install -y \
  mysql-client-core-5.7 \
  openjdk-8-jre-headless \
  postgresql-client \
  unzip \
  wget \
  zip \
  ant \
  && rm -rf /var/lib/apt/lists/*

RUN mkdir /opt/custom-init.d/

# create user to launch Bonita BPM as non-root
RUN groupadd -r bonita -g 1000 \
  && useradd -u 1000 -r -g bonita -d /opt/bonita/ -s /sbin/nologin -c "Bonita User" bonita

# grab gosu
RUN gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4
RUN wget -q "https://github.com/tianon/gosu/releases/download/1.6/gosu-$(dpkg --print-architecture)" -O /usr/local/bin/gosu \
  && wget -q "https://github.com/tianon/gosu/releases/download/1.6/gosu-$(dpkg --print-architecture).asc" -O /usr/local/bin/gosu.asc \
  && gpg --verify /usr/local/bin/gosu.asc \
  && rm /usr/local/bin/gosu.asc \
  && chmod +x /usr/local/bin/gosu

# use --build-arg key=value in docker build command to override arguments
ARG BONITA_VERSION
ARG TOMCAT_VERSION
ARG BONITA_SHA256
ARG BASE_URL
ARG ORACLE_JDBC_DRIVER_SHA256
ARG ORACLE_BASE_URL
ARG BONITA_DBTOOL_SHA256
ARG BONITA_DBTOOL_URL

ENV BONITA_VERSION ${BONITA_VERSION:-7.5.4}
ENV TOMCAT_VERSION ${TOMCAT_VERSION:-7.0.76}
ENV BASE_URL ${BASE_URL:-http://repositories.rd.lan/nas/releases/7.x/7.5.x/${BONITA_VERSION}/BonitaBPMSubscription-${BONITA_VERSION}/}
ENV BONITA_URL ${BASE_URL}/BonitaBPMSubscription-${BONITA_VERSION}-Tomcat-${TOMCAT_VERSION}.zip
ENV BONITA_SHA256  ${BONITA_SHA256:-404b812bbd391920465bc305e62941615e9abea20c2ad1bec4f7389ff75a9bf9}
ENV ORACLE_JDBC_DRIVER ojdbc-6.jar
ENV ORACLE_JDBC_DRIVER_SHA256 ${ORACLE_JDBC_DRIVER_SHA256:-a6e151e3c30efbfb3d86ad729dd2f9136a093815baebcfe81e6d0b26893180b2}
ENV ORACLE_BASE_URL ${ORACLE_BASE_URL:-http://repositories.rd.lan/archiva/repository/releases/com/oracle/ojdbc/6/}
ENV BONITA_DBTOOL_VERSION 7.0.0-06
ENV BONITA_DBTOOL_SHA256 ${BONITA_DBTOOL_SHA256:-8489e2ff8b143909759fd41de621f917419d4078c5f969247702073696e03615}
ENV BONITA_DBTOOL bonita-deployer-${BONITA_DBTOOL_VERSION}-databases
ENV BONITA_DBTOOL_URL ${BONITA_DBTOOL_URL:-http://repositories.rd.lan/archiva/repository/releases/org/bonitasoft/tools/bonita-deployer/${BONITA_DBTOOL_VERSION}}

#cluster
#ENV CLUSTER_MODE true

#create destination folder for downloads
RUN mkdir /opt/files 

# retrieve oracle JDBC drivers
RUN wget -q ${ORACLE_BASE_URL}/${ORACLE_JDBC_DRIVER} -O /opt/files/${ORACLE_JDBC_DRIVER} \
  && echo "$ORACLE_JDBC_DRIVER_SHA256" /opt/files/${ORACLE_JDBC_DRIVER} | sha256sum -c -

# retrieve bonita deployer databasases tool
RUN wget -q ${BONITA_DBTOOL_URL}/${BONITA_DBTOOL}.zip -O /opt/files/${BONITA_DBTOOL}.zip \
  && echo "$BONITA_DBTOOL_SHA256" /opt/files/${BONITA_DBTOOL}.zip | sha256sum -c -

COPY files /opt/files
COPY templates /opt/templates

# add Bonita BPM archive to the container
RUN wget -q ${BONITA_URL} -O /opt/files/BonitaBPMSubscription-${BONITA_VERSION}-Tomcat-${TOMCAT_VERSION}.zip

# display downloaded checksum
RUN sha256sum /opt/files/BonitaBPMSubscription-${BONITA_VERSION}-Tomcat-${TOMCAT_VERSION}.zip

# check with expected checksum
RUN echo "$BONITA_SHA256" /opt/files/BonitaBPMSubscription-${BONITA_VERSION}-Tomcat-${TOMCAT_VERSION}.zip | sha256sum -c -

# create Volume to store Bonita BPM files
VOLUME /opt/bonita

# create Volume to store Bonita BPM licenses (*.lic)
VOLUME /opt/bonita_lic

# expose Tomcat port
EXPOSE 8080

# expose Hazelcast port
EXPOSE 5701

# command to run when the container starts
CMD ["/opt/files/startup.sh"]
