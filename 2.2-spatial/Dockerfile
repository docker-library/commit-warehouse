############################################################
# Dockerfile  for OrientDB with spatial module
############################################################

FROM orientdb:2.2.6

ENV ORIENTDB_DOWNLOAD_SPATIAL_MD5 e4bfb0540e367ad69b05d814ca7e68ba
ENV ORIENTDB_DOWNLOAD_SPATIAL_SHA1 eaae2faa4794b55ea58db5815ec77b2847b1d45d

ENV ORIENTDB_DOWNLOAD_SPATIAL_URL ${ORIENTDB_DOWNLOAD_SERVER:-http://central.maven.org/maven2/com/orientechnologies}/orientdb-spatial/$ORIENTDB_VERSION/orientdb-spatial-$ORIENTDB_VERSION-dist.jar

RUN wget $ORIENTDB_DOWNLOAD_SPATIAL_URL \
    && echo "$ORIENTDB_DOWNLOAD_SPATIAL_MD5 *orientdb-spatial-$ORIENTDB_VERSION-dist.jar" | md5sum -c - \
    && echo "$ORIENTDB_DOWNLOAD_SPATIAL_SHA1 *orientdb-spatial-$ORIENTDB_VERSION-dist.jar" | sha1sum -c - \
    && mv orientdb-spatial-*-dist.jar /orientdb/lib/

