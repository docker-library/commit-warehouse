############################################################
# Dockerfile  for OrientDB with spatial module
############################################################

FROM orientdb:2.2.3

ENV ORIENTDB_DOWNLOAD_SPATIAL_MD5 bc4b7f3a185e7391e2a313caf5ebbb0e
ENV ORIENTDB_DOWNLOAD_SPATIAL_SHA1 f787056fa74a6d49c40a3b3bd426640c7e729b94

ENV ORIENTDB_DOWNLOAD_SPATIAL_URL ${ORIENTDB_DOWNLOAD_SERVER:-http://central.maven.org/maven2/com/orientechnologies}/orientdb-spatial/$ORIENTDB_VERSION/orientdb-spatial-$ORIENTDB_VERSION-dist.jar

RUN wget $ORIENTDB_DOWNLOAD_SPATIAL_URL \
    && echo "$ORIENTDB_DOWNLOAD_SPATIAL_MD5 *orientdb-spatial-$ORIENTDB_VERSION-dist.jar" | md5sum -c - \
    && echo "$ORIENTDB_DOWNLOAD_SPATIAL_SHA1 *orientdb-spatial-$ORIENTDB_VERSION-dist.jar" | sha1sum -c - \
    && mv orientdb-spatial-*-dist.jar /orientdb/lib/

