############################################################
# Dockerfile  for OrientDB with spatial module and neo4j connector
############################################################

FROM orientdb:2.2.32

ENV ORIENTDB_DOWNLOAD_SPATIAL_MD5 6dedf68e0964001c9be4e72450989b50
ENV ORIENTDB_DOWNLOAD_SPATIAL_SHA1 b4affb8dea053cc7b1f11792b1c48cdc41a73fb4

ENV ORIENTDB_DOWNLOAD_SPATIAL_URL ${ORIENTDB_DOWNLOAD_SERVER:-http://central.maven.org/maven2/com/orientechnologies}/orientdb-spatial/$ORIENTDB_VERSION/orientdb-spatial-$ORIENTDB_VERSION-dist.jar

RUN wget $ORIENTDB_DOWNLOAD_SPATIAL_URL \
    && echo "$ORIENTDB_DOWNLOAD_SPATIAL_MD5 *orientdb-spatial-$ORIENTDB_VERSION-dist.jar" | md5sum -c - \
    && echo "$ORIENTDB_DOWNLOAD_SPATIAL_SHA1 *orientdb-spatial-$ORIENTDB_VERSION-dist.jar" | sha1sum -c - \
    && mv orientdb-spatial-*-dist.jar /orientdb/lib/
