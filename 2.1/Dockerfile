############################################################
# Dockerfile to run an OrientDB (Graph) Container
############################################################

FROM java:8-jdk

MAINTAINER Orient Technologies LTD (info@orientdb.com)

ENV ORIENTDB_VERSION 2.1.7

#download distribution tar, untar and delete databases
RUN mkdir /orientdb && \
  wget  "http://central.maven.org/maven2/com/orientechnologies/orientdb-community/$ORIENTDB_VERSION/orientdb-community-$ORIENTDB_VERSION.tar.gz" \
  && wget "http://central.maven.org/maven2/com/orientechnologies/orientdb-community/$ORIENTDB_VERSION/orientdb-community-$ORIENTDB_VERSION.tar.gz.md5" \
  && wget "http://central.maven.org/maven2/com/orientechnologies/orientdb-community/$ORIENTDB_VERSION/orientdb-community-$ORIENTDB_VERSION.tar.gz.sha1" \
  && echo "$(cat orientdb-community-$ORIENTDB_VERSION.tar.gz.md5) *orientdb-community-$ORIENTDB_VERSION.tar.gz" | md5sum -c - \
  && echo "$(cat orientdb-community-$ORIENTDB_VERSION.tar.gz.sha1) *orientdb-community-$ORIENTDB_VERSION.tar.gz" | sha1sum -c - \
  && tar -xvzf orientdb-community-$ORIENTDB_VERSION.tar.gz -C /orientdb --strip-components=1\
  && rm orientdb-community-$ORIENTDB_VERSION.tar.gz* \
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
