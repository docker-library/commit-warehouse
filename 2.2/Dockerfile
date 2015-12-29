############################################################
# Dockerfile to run an OrientDB (Graph) Container
############################################################

FROM java:8-jdk

MAINTAINER OrientDB LTD (info@orientdb.com)

ENV ORIENTDB_VERSION 2.2.0-beta
ENV ORIENTDB_DOWNLOAD_MD5 f41e31ada4acec5e10a192cbe73c798e
ENV ORIENTDB_DOWNLOAD_SHA1 1433e1bd1c43043da6eee8ef782a90ec30e1c716


#download distribution tar, untar and delete databases
RUN mkdir /orientdb && \
  wget  "http://central.maven.org/maven2/com/orientechnologies/orientdb-community/$ORIENTDB_VERSION/orientdb-community-$ORIENTDB_VERSION-distribution.tar.gz" \
  && echo "$ORIENTDB_DOWNLOAD_MD5 *orientdb-community-$ORIENTDB_VERSION-distribution.tar.gz" | md5sum -c - \
  && echo "$ORIENTDB_DOWNLOAD_SHA1 *orientdb-community-$ORIENTDB_VERSION-distribution.tar.gz" | sha1sum -c - \
  && tar -xvzf orientdb-community-$ORIENTDB_VERSION-distribution.tar.gz -C /orientdb --strip-components=1\
  && rm orientdb-community-$ORIENTDB_VERSION-distribution.tar.gz \
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
