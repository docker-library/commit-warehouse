############################################################
# Dockerfile  for OrientDB with spatial module
############################################################

FROM orientdb:2.2.9

ENV ORIENTDB_DOWNLOAD_SPATIAL_MD5 e8b23a42f05b2b5b086e4940c9ec1666
ENV ORIENTDB_DOWNLOAD_SPATIAL_SHA1 fdd1fa06b3fcfd72fadf65ee20c10a37257eabe6

ENV ORIENTDB_DOWNLOAD_SPATIAL_URL ${ORIENTDB_DOWNLOAD_SERVER:-http://central.maven.org/maven2/com/orientechnologies}/orientdb-spatial/$ORIENTDB_VERSION/orientdb-spatial-$ORIENTDB_VERSION-dist.jar

RUN wget $ORIENTDB_DOWNLOAD_SPATIAL_URL \
    && echo "$ORIENTDB_DOWNLOAD_SPATIAL_MD5 *orientdb-spatial-$ORIENTDB_VERSION-dist.jar" | md5sum -c - \
    && echo "$ORIENTDB_DOWNLOAD_SPATIAL_SHA1 *orientdb-spatial-$ORIENTDB_VERSION-dist.jar" | sha1sum -c - \
    && mv orientdb-spatial-*-dist.jar /orientdb/lib/

