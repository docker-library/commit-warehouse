FROM ubuntu:14.04

MAINTAINER Jérémy Jacquier-Roux <jeremy.jacquier-roux@bonitasoft.com>

# install packages
RUN apt-get update && apt-get install -y \
  mysql-client-core-5.5 \
  openjdk-7-jre-headless \
  postgresql-client \
  unzip \
  wget \
  zip \
  && rm -rf /var/lib/apt/lists/*

RUN mkdir /opt/custom-init.d/

# create user to launch Bonita BPM as non-root
RUN groupadd -r bonita -g 1000 \
  && useradd -u 1000 -r -g bonita -d /opt/bonita/ -s /sbin/nologin -c "Bonita User" bonita

# grab gosu
RUN gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4
RUN wget -q "https://github.com/tianon/gosu/releases/download/1.10/gosu-$(dpkg --print-architecture)" -O /usr/local/bin/gosu \
  && wget -q "https://github.com/tianon/gosu/releases/download/1.10/gosu-$(dpkg --print-architecture).asc" -O /usr/local/bin/gosu.asc \
  && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
  && rm /usr/local/bin/gosu.asc \
  && chmod +x /usr/local/bin/gosu

ENV BONITA_VERSION 7.0.3
ENV BASE_URL http://repositories.rd.lan/nas/releases/bonita_platform/7.x/7.0.x/${BONITA_VERSION}/BonitaBPMSubscription-${BONITA_VERSION}/
ENV BONITA_SHA256 3d95898a0e6bab26da0fcefe12e0f6b51b66cf84a6bafd473a5758839c7877f1
ENV POSTGRES_JDBC_DRIVER postgresql-9.3-1102.jdbc41.jar
ENV POSTGRES_SHA256 b78749d536da75c382d0a71c717cde6850df64e16594676fc7cacb5a74541d66
ENV MYSQL_JDBC_DRIVER mysql-connector-java-5.1.26
ENV MYSQL_SHA256 40b2d49f6f2551cc7fa54552af806e8026bf8405f03342205852e57a3205a868

#cluster
#ENV CLUSTER_MODE true

# retrieve JDBC drivers
RUN mkdir /opt/files \
  && wget -q https://jdbc.postgresql.org/download/${POSTGRES_JDBC_DRIVER} -O /opt/files/${POSTGRES_JDBC_DRIVER} \
  && echo "$POSTGRES_SHA256" /opt/files/${POSTGRES_JDBC_DRIVER} | sha256sum -c - \
  && wget -q http://dev.mysql.com/get/Downloads/Connector-J/${MYSQL_JDBC_DRIVER}.zip -O /opt/files/${MYSQL_JDBC_DRIVER}.zip \
  && echo "$MYSQL_SHA256" /opt/files/${MYSQL_JDBC_DRIVER}.zip | sha256sum -c - \
  && unzip -q /opt/files/${MYSQL_JDBC_DRIVER}.zip -d /opt/files/ \
  && mv /opt/files/${MYSQL_JDBC_DRIVER}/${MYSQL_JDBC_DRIVER}-bin.jar /opt/files/ \
  && rm -r /opt/files/${MYSQL_JDBC_DRIVER} \
  && rm /opt/files/${MYSQL_JDBC_DRIVER}.zip

COPY files /opt/files
COPY templates /opt/templates

# add Bonita BPM archive to the container
RUN wget -q ${BASE_URL}/BonitaBPMSubscription-${BONITA_VERSION}-Tomcat-7.0.55.zip -O /opt/files/BonitaBPMSubscription-${BONITA_VERSION}-Tomcat-7.0.55.zip \
  && echo "$BONITA_SHA256" /opt/files/BonitaBPMSubscription-${BONITA_VERSION}-Tomcat-7.0.55.zip | sha256sum -c -

# create Volume to store Bonita BPM files
VOLUME /opt/bonita

#cluster
VOLUME /opt/bonita_home

# expose Tomcat port
EXPOSE 8080

# expose Hazelcast port
EXPOSE 5701

# command to run when the container starts
CMD ["/opt/files/startup.sh"]
