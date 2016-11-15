############################################################
# Dockerfile  for OrientDB with spatial module and neo4j connector
############################################################

FROM orientdb:2.2.13

ENV ORIENTDB_DOWNLOAD_SPATIAL_MD5 86d691cbd2a5169519f3a29723835ec5
ENV ORIENTDB_DOWNLOAD_SPATIAL_SHA1 c82e0e644b5bd37b29391724ff0802df2a2ee9bc

ENV ORIENTDB_DOWNLOAD_SPATIAL_URL ${ORIENTDB_DOWNLOAD_SERVER:-http://central.maven.org/maven2/com/orientechnologies}/orientdb-spatial/$ORIENTDB_VERSION/orientdb-spatial-$ORIENTDB_VERSION-dist.jar

RUN wget $ORIENTDB_DOWNLOAD_SPATIAL_URL \
    && echo "$ORIENTDB_DOWNLOAD_SPATIAL_MD5 *orientdb-spatial-$ORIENTDB_VERSION-dist.jar" | md5sum -c - \
    && echo "$ORIENTDB_DOWNLOAD_SPATIAL_SHA1 *orientdb-spatial-$ORIENTDB_VERSION-dist.jar" | sha1sum -c - \
    && mv orientdb-spatial-*-dist.jar /orientdb/lib/
