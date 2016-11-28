FROM java:8-jre
MAINTAINER Nikolche Mihajlovski

# GPG key of Rapidoid's author/maintainer (616EF49C: Nikolche Mihajlovski <nikolce.mihajlovski@gmail.com>)
ENV GPG_KEY E306FEF548C686C23DC00242B9B08D8F616EF49C

ENV RAPIDOID_JAR /opt/rapidoid.jar
ENV RAPIDOID_TMP /tmp/rapidoid

WORKDIR /opt
EXPOSE 8888

ENV RAPIDOID_VERSION 5.2.6
ENV RAPIDOID_URL https://repo1.maven.org/maven2/org/rapidoid/rapidoid-platform/$RAPIDOID_VERSION/rapidoid-platform-$RAPIDOID_VERSION.jar

COPY entrypoint.sh /opt/

RUN set -xe \
    && mkdir /app \
    && mkdir -p "$RAPIDOID_TMP" \
	&& curl -SL "$RAPIDOID_URL" -o $RAPIDOID_JAR \
	&& curl -SL "$RAPIDOID_URL.asc" -o $RAPIDOID_JAR.asc \
	&& export GNUPGHOME="$(mktemp -d)" \
	&& gpg --keyserver ha.pool.sks-keyservers.net --recv-keys $GPG_KEY \
	&& gpg --batch --verify $RAPIDOID_JAR.asc $RAPIDOID_JAR \
	&& rm -r "$GNUPGHOME" \
	&& rm "$RAPIDOID_JAR.asc"

ENTRYPOINT ["/opt/entrypoint.sh"]
