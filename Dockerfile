FROM java:8-jre
MAINTAINER Nikolche Mihajlovski

ENV RAPIDOID_HOME=/usr/local/rapidoid
ENV RAPIDOID_JAR=$RAPIDOID_HOME/rapidoid.jar
ENV RAPIDOID_BASE=/var/lib/rapidoid
ENV RAPIDOID_RUN=/run/rapidoid
ENV RAPIDOID_TMP=/tmp/rapidoid
ENV RAPIDOID_BIN=/usr/local/bin/rapidoid

# GPG key of the Rapidoid author (616EF49C: Nikolche Mihajlovski <nikolce.mihajlovski@gmail.com>)
ENV GPG_KEY E306FEF548C686C23DC00242B9B08D8F616EF49C

RUN set -xe \
 && mkdir -p "$RAPIDOID_HOME" "$RAPIDOID_BASE" "$RAPIDOID_RUN" "$RAPIDOID_TMP"

RUN echo '#!/usr/bin/env bash' > "$RAPIDOID_BIN" \
 && echo 'java -Djava.io.tmpdir="$RAPIDOID_TMP" -cp "$RAPIDOID_JAR:/app/app.jar:/app/*.jar" org.rapidoid.standalone.Main app.jar=/app/app.jar root=/app $@' >> "$RAPIDOID_BIN" \
 && chmod ugo+x "$RAPIDOID_BIN"

ENV RAPIDOID_VERSION 5.1.9
ENV RAPIDOID_URL https://repo1.maven.org/maven2/org/rapidoid/rapidoid-standalone/$RAPIDOID_VERSION/rapidoid-standalone-$RAPIDOID_VERSION.jar

RUN set -xe \
	&& curl -SL "$RAPIDOID_URL" -o $RAPIDOID_JAR \
	&& curl -SL "$RAPIDOID_URL.asc" -o $RAPIDOID_JAR.asc \
	&& export GNUPGHOME="$(mktemp -d)" \
	&& gpg --keyserver ha.pool.sks-keyservers.net --recv-keys $GPG_KEY \
	&& gpg --batch --verify $RAPIDOID_JAR.asc $RAPIDOID_JAR \
	&& rm -r "$GNUPGHOME"

RUN chmod ugo+r $RAPIDOID_JAR

RUN mkdir -p /app
VOLUME /app

WORKDIR $RAPIDOID_BASE
EXPOSE 8888

ENTRYPOINT ["rapidoid"]
CMD ["production"]
