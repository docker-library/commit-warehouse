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
  ant \
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

ENV BONITA_VERSION 7.1.5
ENV BASE_URL http://repositories.rd.lan/nas/releases/bonita_platform/7.x/7.1.x/${BONITA_VERSION}/BonitaBPMSubscription-${BONITA_VERSION}/
ENV BONITA_SHA256 6fbc7f56c4f777e89b5477bf2d8a803cfe3bd515ae18ce3bd0768345dd646294
ENV POSTGRES_JDBC_DRIVER postgresql-9.3-1102.jdbc41.jar
ENV POSTGRES_SHA256 b78749d536da75c382d0a71c717cde6850df64e16594676fc7cacb5a74541d66
ENV MYSQL_JDBC_DRIVER mysql-connector-java-5.1.26
ENV MYSQL_SHA256 40b2d49f6f2551cc7fa54552af806e8026bf8405f03342205852e57a3205a868
ENV ORACLE_JDBC_DRIVER ojdbc-6.jar
ENV ORACLE_SHA256 a6e151e3c30efbfb3d86ad729dd2f9136a093815baebcfe81e6d0b26893180b2
ENV BONITA_DBTOOL_VERSION 7.0.0-05
ENV BONITA_DBTOOL_SHA256 33280c0b4591620f03b97436e577de6573b00abf7e494db45470a807f5ecdfcb
ENV BONITA_DBTOOL bonita-deployer-${BONITA_DBTOOL_VERSION}-databases

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
  && rm /opt/files/${MYSQL_JDBC_DRIVER}.zip \
  && wget -q http://repositories.rd.lan/archiva/repository/releases/com/oracle/ojdbc/6/${ORACLE_JDBC_DRIVER} -O /opt/files/${ORACLE_JDBC_DRIVER} \
  && echo "$ORACLE_SHA256" /opt/files/${ORACLE_JDBC_DRIVER} | sha256sum -c -

# retrieve bonita deployer databasases tool
RUN wget -q http://repositories.rd.lan/archiva/repository/releases/org/bonitasoft/tools/bonita-deployer/${BONITA_DBTOOL_VERSION}/${BONITA_DBTOOL}.zip -O /opt/files/${BONITA_DBTOOL}.zip \
  && echo "$BONITA_DBTOOL_SHA256" /opt/files/${BONITA_DBTOOL}.zip | sha256sum -c -

COPY files /opt/files
COPY templates /opt/templates

RUN echo "$ORACLE_SHA256" /opt/files/${ORACLE_JDBC_DRIVER} | sha256sum -c -

# add Bonita BPM archive to the container
### Get Bonita from local files
#COPY files/BonitaBPMSubscription-${BONITA_VERSION}-Tomcat-7.0.55.zip /opt/files/BonitaBPMSubscription-${BONITA_VERSION}-Tomcat-7.0.55.zip
# Get Bonita from URL
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
