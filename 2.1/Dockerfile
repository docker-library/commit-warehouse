############################################################
# Dockerfile to run an OrientDB (Graph) Container
############################################################

FROM java:8-jdk

MAINTAINER Orient Technologies LTD (info@orientdb.com)

ENV ORIENTDB_VERSION 2.1.6
ENV ORIENTDB_DOWNLOAD_SHA256 5ac1b706bc997a8e3de603aa1a9a07619900bf1b

#download distribution tar, untar and delete databases
RUN mkdir /orientdb && \
  wget  "http://central.maven.org/maven2/com/orientechnologies/orientdb-community/$ORIENTDB_VERSION/orientdb-community-$ORIENTDB_VERSION.tar.gz" \
  && echo "$ORIENTDB_DOWNLOAD_SHA256 *orientdb-community-$ORIENTDB_VERSION.tar.gz" | sha256sum -c - \
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
