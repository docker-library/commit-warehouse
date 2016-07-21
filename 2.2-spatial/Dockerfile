############################################################
# Dockerfile  for OrientDB with spatial module
############################################################

FROM orientdb:2.2.5

ENV ORIENTDB_DOWNLOAD_SPATIAL_MD5 8b2f6834a55a6219a20598790e62d34c
ENV ORIENTDB_DOWNLOAD_SPATIAL_SHA1 2a07a67b30698ffe61ed7cf1d4d20b38d3d3843e

ENV ORIENTDB_DOWNLOAD_SPATIAL_URL ${ORIENTDB_DOWNLOAD_SERVER:-http://central.maven.org/maven2/com/orientechnologies}/orientdb-spatial/$ORIENTDB_VERSION/orientdb-spatial-$ORIENTDB_VERSION-dist.jar

RUN wget $ORIENTDB_DOWNLOAD_SPATIAL_URL \
    && echo "$ORIENTDB_DOWNLOAD_SPATIAL_MD5 *orientdb-spatial-$ORIENTDB_VERSION-dist.jar" | md5sum -c - \
    && echo "$ORIENTDB_DOWNLOAD_SPATIAL_SHA1 *orientdb-spatial-$ORIENTDB_VERSION-dist.jar" | sha1sum -c - \
    && mv orientdb-spatial-*-dist.jar /orientdb/lib/

