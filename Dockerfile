FROM java:8-jre
MAINTAINER Nikolche Mihajlovski

ENV RAPIDOID_VERSION 5.1.9
ENV RAPIDOID_JAR /opt/rapidoid.jar
ENV RAPIDOID_TMP /tmp/rapidoid
ENV RAPIDOID_URL https://repo1.maven.org/maven2/org/rapidoid/rapidoid-standalone/$RAPIDOID_VERSION/rapidoid-standalone-$RAPIDOID_VERSION.jar

# GPG key of Rapidoid's author (616EF49C: Nikolche Mihajlovski <nikolce.mihajlovski@gmail.com>)
ENV GPG_KEY E306FEF548C686C23DC00242B9B08D8F616EF49C

VOLUME /app
WORKDIR /opt
EXPOSE 8888

COPY entrypoint.sh /opt/

RUN set -xe \
    && mkdir -p "$RAPIDOID_TMP" \
	&& curl -SL "$RAPIDOID_URL" -o $RAPIDOID_JAR \
	&& curl -SL "$RAPIDOID_URL.asc" -o $RAPIDOID_JAR.asc \
	&& export GNUPGHOME="$(mktemp -d)" \
	&& gpg --keyserver ha.pool.sks-keyservers.net --recv-keys $GPG_KEY \
	&& gpg --batch --verify $RAPIDOID_JAR.asc $RAPIDOID_JAR \
	&& rm -r "$GNUPGHOME" \
	&& rm "$RAPIDOID_JAR.asc" \
	&& chmod 444 $RAPIDOID_JAR \
	&& chmod 555 /opt/entrypoint.sh

ENTRYPOINT ["/opt/entrypoint.sh"]
CMD ["production"]
