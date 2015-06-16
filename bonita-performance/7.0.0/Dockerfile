FROM ubuntu:14.04

MAINTAINER Jérémy Jacquier-Roux <jeremy.jacquier-roux@bonitasoft.com>

ENV BONITA_VERSION 7.0.0
ENV TOMCAT_VERSION 7.0.55
ENV BONITA_ARCHIVE_DIR BonitaBPMSubscription-${BONITA_VERSION}-Tomcat-${TOMCAT_VERSION}
ENV BONITA_ARCHIVE_FILE ${BONITA_ARCHIVE_DIR}.zip
ENV BONITA_DOWNLOAD_SHA256 6a8758e2e829376c12ce6fcae754222fbfbfc739d0b78817b7e43117c5ee77de
#ENV BASE_URL http://download.forge.ow2.org/bonita
ENV BASE_URL http://192.168.1.254/qa/releases/7.0.x/${BONITA_VERSION}/BonitaBPMSubscription-${BONITA_VERSION}/
ENV POSTGRES_JDBC_DRIVER_FILE postgresql-9.3-1102.jdbc41.jar
ENV POSTGRES_JDBC_DRIVER_URL https://jdbc.postgresql.org/download/${POSTGRES_JDBC_DRIVER_FILE}
ENV MYSQL_JDBC_DRIVER_NAME mysql-connector-java-5.1.26
ENV MYSQL_JDBC_DRIVER_URL http://dev.mysql.com/get/Downloads/Connector-J/${MYSQL_JDBC_DRIVER_NAME}.zip
ENV MYSQL_JDBC_DRIVER_FILE ${MYSQL_JDBC_DRIVER_NAME}-bin.jar

#cluster
#ENV CLUSTER_MODE true

# perf
#ENV BENCH_MODE true
ENV BENCH_URL_ACTIVEMQ http://central.maven.org/maven2/org/apache/activemq/activemq-client/5.8.0/activemq-client-5.8.0.jar
ENV BENCH_URL_HAWTBUF http://central.maven.org/maven2/org/fusesource/hawtbuf/hawtbuf/1.9/hawtbuf-1.9.jar
ENV BENCH_URL_GERONIMO_JMS http://central.maven.org/maven2/org/apache/geronimo/specs/geronimo-jms_1.1_spec/1.1.1/geronimo-jms_1.1_spec-1.1.1.jar
ENV BENCH_URL_GERONIMO_J2EE http://central.maven.org/maven2/org/apache/geronimo/specs/geronimo-j2ee-management_1.1_spec/1.0.1/geronimo-j2ee-management_1.1_spec-1.0.1.jar

# avoid debconf messages
ENV DEBIAN_FRONTEND noninteractive

# install packages
RUN apt-get update && apt-get install -y \
  mysql-client-core-5.5 \
  openjdk-7-jre-headless \
  postgresql-client \
  unzip \
  wget \
  zip \
  && rm -rf /var/lib/apt/lists/*

COPY files /opt/files
COPY templates /opt/templates

# retrieve JDBC drivers
ADD ${POSTGRES_JDBC_DRIVER_URL} /opt/files/
RUN wget -q ${MYSQL_JDBC_DRIVER_URL} -O /opt/files/${MYSQL_JDBC_DRIVER_NAME}.zip \
  && unzip -q /opt/files/${MYSQL_JDBC_DRIVER_NAME}.zip -d /opt/files/ \
  && mv /opt/files/${MYSQL_JDBC_DRIVER_NAME}/${MYSQL_JDBC_DRIVER_FILE} /opt/files/ \
  && rm -r /opt/files/${MYSQL_JDBC_DRIVER_NAME} \
  && rm /opt/files/${MYSQL_JDBC_DRIVER_NAME}.zip

# add benchmark needed jars
ADD ${BENCH_URL_ACTIVEMQ} /opt/files/bench/
ADD ${BENCH_URL_HAWTBUF} /opt/files/bench/
ADD ${BENCH_URL_GERONIMO_JMS} /opt/files/bench/
ADD ${BENCH_URL_GERONIMO_J2EE} /opt/files/bench/

# add Bonita BPM archive to the container
RUN wget -q ${BASE_URL}/${BONITA_ARCHIVE_FILE} -O /opt/files/${BONITA_ARCHIVE_FILE} \
  &&  echo "$BONITA_DOWNLOAD_SHA256" /opt/files/${BONITA_ARCHIVE_FILE} | sha256sum -c -

# create Volume to store Bonita BPM files
VOLUME /opt/bonita

#cluster
VOLUME /opt/bonita_home

# create user to launch Bonita BPM as non-root
RUN groupadd -r bonita -g 222 \
  && useradd -u 222 -r -g bonita -d /opt/bonita/ -s /sbin/nologin -c "Bonita User" bonita

# expose Tomcat port
EXPOSE 8080

# expose Hazelcast port
EXPOSE 5701

# command to run when the container starts
CMD ["/opt/files/startup.sh"]
