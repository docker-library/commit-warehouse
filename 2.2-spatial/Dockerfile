############################################################
# Dockerfile  for OrientDB with spatial module
############################################################

FROM orientdb:2.2.10

ENV ORIENTDB_DOWNLOAD_SPATIAL_MD5 8ce30154d3c9ac807aef7b0172470612
ENV ORIENTDB_DOWNLOAD_SPATIAL_SHA1 0fcb2b1744a21db695962b4cf854498d7cfda9dd

ENV ORIENTDB_DOWNLOAD_SPATIAL_URL ${ORIENTDB_DOWNLOAD_SERVER:-http://central.maven.org/maven2/com/orientechnologies}/orientdb-spatial/$ORIENTDB_VERSION/orientdb-spatial-$ORIENTDB_VERSION-dist.jar

RUN wget $ORIENTDB_DOWNLOAD_SPATIAL_URL \
    && echo "$ORIENTDB_DOWNLOAD_SPATIAL_MD5 *orientdb-spatial-$ORIENTDB_VERSION-dist.jar" | md5sum -c - \
    && echo "$ORIENTDB_DOWNLOAD_SPATIAL_SHA1 *orientdb-spatial-$ORIENTDB_VERSION-dist.jar" | sha1sum -c - \
    && mv orientdb-spatial-*-dist.jar /orientdb/lib/

