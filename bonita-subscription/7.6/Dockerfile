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

# create user to launch Bonita as non-root
RUN groupadd -r bonita -g 1000 \
  && useradd -u 1000 -r -g bonita -d /opt/bonita/ -s /sbin/nologin -c "Bonita User" bonita

# grab gosu
RUN gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
  && curl -sSL "https://github.com/tianon/gosu/releases/download/1.6/gosu-$(dpkg --print-architecture)" -o /usr/local/bin/gosu \
  && curl -sSL "https://github.com/tianon/gosu/releases/download/1.6/gosu-$(dpkg --print-architecture).asc" -o /tmp/gosu.asc \
  && gpg --batch --verify /tmp/gosu.asc /usr/local/bin/gosu \
  && rm /tmp/gosu.asc \
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

ENV BONITA_VERSION ${BONITA_VERSION:-7.6.0.beta-02}
ENV TOMCAT_VERSION ${TOMCAT_VERSION:-8.5.23}
ENV BASE_URL ${BASE_URL:-http://repositories.rd.lan/nas/releases/_Early_Access/20171025_195149/${BONITA_VERSION}/BonitaSubscription-${BONITA_VERSION}/}
ENV BONITA_URL ${BASE_URL}/BonitaSubscription-${BONITA_VERSION}-Tomcat-${TOMCAT_VERSION}.zip
ENV BONITA_SHA256  ${BONITA_SHA256:-9b02525fd1faa82ff6136809cc3df28534ef3d9280d9799b81ba61060e0c749a}
ENV ORACLE_JDBC_DRIVER ojdbc-6.jar
ENV ORACLE_JDBC_DRIVER_SHA256 ${ORACLE_JDBC_DRIVER_SHA256:-a6e151e3c30efbfb3d86ad729dd2f9136a093815baebcfe81e6d0b26893180b2}
ENV ORACLE_BASE_URL ${ORACLE_BASE_URL:-http://repositories.rd.lan/archiva/repository/releases/com/oracle/ojdbc/6/}
ENV BONITA_DBTOOL_VERSION 7.0.0-06
ENV BONITA_DBTOOL_SHA256 ${BONITA_DBTOOL_SHA256:-8489e2ff8b143909759fd41de621f917419d4078c5f969247702073696e03615}
ENV BONITA_DBTOOL bonita-deployer-${BONITA_DBTOOL_VERSION}-databases
ENV BONITA_DBTOOL_URL ${BONITA_DBTOOL_URL:-http://repositories.rd.lan/archiva/repository/releases/org/bonitasoft/tools/bonita-deployer/${BONITA_DBTOOL_VERSION}}

# create destination folder for downloads
RUN mkdir /opt/custom-init.d/ \
  && mkdir /opt/files

# retrieve oracle JDBC drivers
# retrieve bonita deployer databasases tool
RUN curl -sSL ${ORACLE_BASE_URL}/${ORACLE_JDBC_DRIVER} -o /opt/files/${ORACLE_JDBC_DRIVER} \
  && echo "$ORACLE_JDBC_DRIVER_SHA256" /opt/files/${ORACLE_JDBC_DRIVER} | sha256sum -c - \
  && curl -sSL ${BONITA_DBTOOL_URL}/${BONITA_DBTOOL}.zip -o /opt/files/${BONITA_DBTOOL}.zip \
  && echo "$BONITA_DBTOOL_SHA256" /opt/files/${BONITA_DBTOOL}.zip | sha256sum -c -

COPY files /opt/files
COPY templates /opt/templates

# add Bonita archive to the container
RUN curl -sSL ${BONITA_URL} -o /opt/files/BonitaSubscription-${BONITA_VERSION}-Tomcat-${TOMCAT_VERSION}.zip \
  && sha256sum /opt/files/BonitaSubscription-${BONITA_VERSION}-Tomcat-${TOMCAT_VERSION}.zip \
  && echo "$BONITA_SHA256" /opt/files/BonitaSubscription-${BONITA_VERSION}-Tomcat-${TOMCAT_VERSION}.zip | sha256sum -c -

# create Volume to store Bonita files
VOLUME /opt/bonita

# create Volume to store Bonita licenses (*.lic)
VOLUME /opt/bonita_lic

# expose Tomcat port
EXPOSE 8080

# expose Hazelcast port
EXPOSE 5701

# command to run when the container starts
CMD ["/opt/files/startup.sh"]
