############################################################
# Dockerfile to run an OrientDB (Graph) Container
############################################################

FROM java:openjdk-8-jdk-alpine

MAINTAINER OrientDB LTD (info@orientdb.com)

ENV ORIENTDB_VERSION 2.1.19
ENV ORIENTDB_DOWNLOAD_MD5 11942093675c32b9341658bd56f191f0
ENV ORIENTDB_DOWNLOAD_SHA1 289b5d0950254e90531e65a3f4ef530bb4193f32

RUN apk add --update tar \
    && rm -rf /var/cache/apk/*

#download distribution tar, untar and delete databases
RUN mkdir /orientdb && \
  wget  "http://central.maven.org/maven2/com/orientechnologies/orientdb-community/$ORIENTDB_VERSION/orientdb-community-$ORIENTDB_VERSION.tar.gz" \
  && echo "$ORIENTDB_DOWNLOAD_MD5 *orientdb-community-$ORIENTDB_VERSION.tar.gz" | md5sum -c - \
  && echo "$ORIENTDB_DOWNLOAD_SHA1 *orientdb-community-$ORIENTDB_VERSION.tar.gz" | sha1sum -c - \
  && tar -xvzf orientdb-community-$ORIENTDB_VERSION.tar.gz -C /orientdb --strip-components=1\
  && rm orientdb-community-$ORIENTDB_VERSION.tar.gz \
  && rm -rf /orientdb/databases/*


ENV PATH /orientdb/bin:$PATH

VOLUME ["/orientdb/backup", "/orientdb/databases", "/orientdb/config"]

WORKDIR /orientdb

#OrientDb binary
EXPOSE 2424

#OrientDb http
EXPOSE 2480

# Default command start the server
CMD ["server.sh"]
