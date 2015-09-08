############################################################
# Dockerfile to run an OrientDB (Graph) Container
############################################################

FROM azul/zulu-openjdk:8

MAINTAINER Orient Technologies LTD (info@orientdb.com)

RUN apt-get update

RUN apt-get -y install wget gzip

ENV ORIENTDB_VERSION 2.2.0

#download distribution tar, untar and delete databases
RUN mkdir /orientdb && \
  wget -O orientdb-community-$ORIENTDB_VERSION.tar.gz "http://orientdb.com/download.php?email=unknown@unknown.com&file=orientdb-community-$ORIENTDB_VERSION.tar.gz&os=linux" \
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

# Set the user to run OrientDB daemon
USER root

# Default command start the server
CMD ["/orientdb/bin/server.sh"]
