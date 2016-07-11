############################################################
# Dockerfile  for OrientDB with spatial module
############################################################

FROM orientdb:2.2.4

ENV ORIENTDB_DOWNLOAD_SPATIAL_MD5 b35097fc9767cf01a1dc3c97332c49e1
ENV ORIENTDB_DOWNLOAD_SPATIAL_SHA1 cdae8552fd76b0277967385b822b3d231824b8b9

ENV ORIENTDB_DOWNLOAD_SPATIAL_URL ${ORIENTDB_DOWNLOAD_SERVER:-http://central.maven.org/maven2/com/orientechnologies}/orientdb-spatial/$ORIENTDB_VERSION/orientdb-spatial-$ORIENTDB_VERSION-dist.jar

RUN wget $ORIENTDB_DOWNLOAD_SPATIAL_URL \
    && echo "$ORIENTDB_DOWNLOAD_SPATIAL_MD5 *orientdb-spatial-$ORIENTDB_VERSION-dist.jar" | md5sum -c - \
    && echo "$ORIENTDB_DOWNLOAD_SPATIAL_SHA1 *orientdb-spatial-$ORIENTDB_VERSION-dist.jar" | sha1sum -c - \
    && mv orientdb-spatial-*-dist.jar /orientdb/lib/

