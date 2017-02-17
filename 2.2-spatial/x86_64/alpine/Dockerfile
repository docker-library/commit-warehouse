############################################################
# Dockerfile  for OrientDB with spatial module and neo4j connector
############################################################

FROM orientdb:2.2.17

ENV ORIENTDB_DOWNLOAD_SPATIAL_MD5 85455721c924fd76f5fe4b81ebd37e8b
ENV ORIENTDB_DOWNLOAD_SPATIAL_SHA1 3c2ccb4c1a368e8f8ab5ef2e417422dec3d26041

ENV ORIENTDB_DOWNLOAD_SPATIAL_URL ${ORIENTDB_DOWNLOAD_SERVER:-http://central.maven.org/maven2/com/orientechnologies}/orientdb-spatial/$ORIENTDB_VERSION/orientdb-spatial-$ORIENTDB_VERSION-dist.jar

RUN wget $ORIENTDB_DOWNLOAD_SPATIAL_URL \
    && echo "$ORIENTDB_DOWNLOAD_SPATIAL_MD5 *orientdb-spatial-$ORIENTDB_VERSION-dist.jar" | md5sum -c - \
    && echo "$ORIENTDB_DOWNLOAD_SPATIAL_SHA1 *orientdb-spatial-$ORIENTDB_VERSION-dist.jar" | sha1sum -c - \
    && mv orientdb-spatial-*-dist.jar /orientdb/lib/
