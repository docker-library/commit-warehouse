############################################################
# Dockerfile  for OrientDB with spatial module
############################################################

FROM orientdb:2.2.0-rc1

ENV ORIENTDB_DOWNLOAD_SPATIAL_MD5 9446a1d1b0231639af977659531cbf64
ENV ORIENTDB_DOWNLOAD_SPATIAL_SHA1 70fabd2dc62fc5f758e4d2b91561c9fcee8f4e14

ENV ORIENTDB_DOWNLOAD_SPATIAL_URL ${ORIENTDB_DOWNLOAD_SERVER:-http://central.maven.org/maven2/com/orientechnologies}/orientdb-spatial/$ORIENTDB_VERSION/orientdb-spatial-$ORIENTDB_VERSION-dist.jar

RUN wget $ORIENTDB_DOWNLOAD_SPATIAL_URL \
    && echo "$ORIENTDB_DOWNLOAD_SPATIAL_MD5 *orientdb-spatial-$ORIENTDB_VERSION-dist.jar" | md5sum -c - \
    && echo "$ORIENTDB_DOWNLOAD_SPATIAL_SHA1 *orientdb-spatial-$ORIENTDB_VERSION-dist.jar" | sha1sum -c - \
    && mv orientdb-spatial-*-dist.jar /orientdb/lib/

