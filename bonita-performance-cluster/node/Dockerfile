FROM ci-01.rd.lan:5000/bonitacloud/bonita-performance_6.4.2

MAINTAINER Guillaume Rosinosky <guillaume.rosinosky@bonitasoft.com>

ENV BASE_URL http://192.168.1.254/qa/releases/${BONITA_VERSION}/BonitaBPMSubscription-${BONITA_VERSION}/
ENV BONITA_HOME_FILE bonita-home-sp-${BONITA_VERSION}-performance-cluster.zip
ADD ${BASE_URL}/${BONITA_HOME_FILE} /opt/files/
COPY setenv.sh.cluster /opt/templates/setenv.sh
COPY bonita-platform.properties.cluster /opt/templates/bonita-platform.properties
COPY config.sh.cluster /opt/files/config.sh
VOLUME /opt/bonita_home
EXPOSE 5701
