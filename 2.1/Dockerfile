############################################################
# Dockerfile to run an OrientDB (Graph) Container
############################################################

FROM java:8-jdk

MAINTAINER OrientDB LTD (info@orientdb.com)

ENV ORIENTDB_VERSION 2.1.14
ENV ORIENTDB_DOWNLOAD_MD5 9aac09434f037f10586b3e8b2c76586f
ENV ORIENTDB_DOWNLOAD_SHA1 045189a3032949b0a7fb212ae9dae77f4a9dc044

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
