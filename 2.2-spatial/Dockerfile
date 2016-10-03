############################################################
# Dockerfile  for OrientDB with spatial module
############################################################

FROM orientdb:2.2.11

ENV ORIENTDB_DOWNLOAD_SPATIAL_MD5 7b8f49fdd2e5dbefe1b9ec1362e11934
ENV ORIENTDB_DOWNLOAD_SPATIAL_SHA1 acdfd82da989dc46a1237b39daf180a3a762ae22

ENV ORIENTDB_DOWNLOAD_SPATIAL_URL ${ORIENTDB_DOWNLOAD_SERVER:-http://central.maven.org/maven2/com/orientechnologies}/orientdb-spatial/$ORIENTDB_VERSION/orientdb-spatial-$ORIENTDB_VERSION-dist.jar

RUN wget $ORIENTDB_DOWNLOAD_SPATIAL_URL \
    && echo "$ORIENTDB_DOWNLOAD_SPATIAL_MD5 *orientdb-spatial-$ORIENTDB_VERSION-dist.jar" | md5sum -c - \
    && echo "$ORIENTDB_DOWNLOAD_SPATIAL_SHA1 *orientdb-spatial-$ORIENTDB_VERSION-dist.jar" | sha1sum -c - \
    && mv orientdb-spatial-*-dist.jar /orientdb/lib/

