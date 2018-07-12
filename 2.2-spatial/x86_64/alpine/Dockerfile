############################################################
# Dockerfile  for OrientDB with spatial module and neo4j connector
############################################################

FROM orientdb:2.2.36

ENV ORIENTDB_DOWNLOAD_SPATIAL_MD5 701d773bb049b7e87d638d7666e7cf56
ENV ORIENTDB_DOWNLOAD_SPATIAL_SHA1 528ab1d5d81246e7034679df42e2ef787a39370b

ENV ORIENTDB_DOWNLOAD_SPATIAL_URL ${ORIENTDB_DOWNLOAD_SERVER:-http://central.maven.org/maven2/com/orientechnologies}/orientdb-spatial/$ORIENTDB_VERSION/orientdb-spatial-$ORIENTDB_VERSION-dist.jar

RUN wget $ORIENTDB_DOWNLOAD_SPATIAL_URL \
    && echo "$ORIENTDB_DOWNLOAD_SPATIAL_MD5 *orientdb-spatial-$ORIENTDB_VERSION-dist.jar" | md5sum -c - \
    && echo "$ORIENTDB_DOWNLOAD_SPATIAL_SHA1 *orientdb-spatial-$ORIENTDB_VERSION-dist.jar" | sha1sum -c - \
    && mv orientdb-spatial-*-dist.jar /orientdb/lib/
