############################################################
# Dockerfile  for OrientDB with spatial module
############################################################

FROM orientdb:2.2.8

ENV ORIENTDB_DOWNLOAD_SPATIAL_MD5 0daf45c5959192707c77b3d58b6e76ad
ENV ORIENTDB_DOWNLOAD_SPATIAL_SHA1 b02eaeaa79ee4477a300d7a53eaee36bd53938d8

ENV ORIENTDB_DOWNLOAD_SPATIAL_URL ${ORIENTDB_DOWNLOAD_SERVER:-http://central.maven.org/maven2/com/orientechnologies}/orientdb-spatial/$ORIENTDB_VERSION/orientdb-spatial-$ORIENTDB_VERSION-dist.jar

RUN wget $ORIENTDB_DOWNLOAD_SPATIAL_URL \
    && echo "$ORIENTDB_DOWNLOAD_SPATIAL_MD5 *orientdb-spatial-$ORIENTDB_VERSION-dist.jar" | md5sum -c - \
    && echo "$ORIENTDB_DOWNLOAD_SPATIAL_SHA1 *orientdb-spatial-$ORIENTDB_VERSION-dist.jar" | sha1sum -c - \
    && mv orientdb-spatial-*-dist.jar /orientdb/lib/

