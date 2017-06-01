############################################################
# Dockerfile  for OrientDB with spatial module and neo4j connector
############################################################

FROM orientdb:2.2.21

ENV ORIENTDB_DOWNLOAD_SPATIAL_MD5 4e166caaaf1f0b03959d8d697d5903fb
ENV ORIENTDB_DOWNLOAD_SPATIAL_SHA1 e849521c1b624bc628449659c31fcabf1a617eaf

ENV ORIENTDB_DOWNLOAD_SPATIAL_URL ${ORIENTDB_DOWNLOAD_SERVER:-http://central.maven.org/maven2/com/orientechnologies}/orientdb-spatial/$ORIENTDB_VERSION/orientdb-spatial-$ORIENTDB_VERSION-dist.jar

RUN wget $ORIENTDB_DOWNLOAD_SPATIAL_URL \
    && echo "$ORIENTDB_DOWNLOAD_SPATIAL_MD5 *orientdb-spatial-$ORIENTDB_VERSION-dist.jar" | md5sum -c - \
    && echo "$ORIENTDB_DOWNLOAD_SPATIAL_SHA1 *orientdb-spatial-$ORIENTDB_VERSION-dist.jar" | sha1sum -c - \
    && mv orientdb-spatial-*-dist.jar /orientdb/lib/
