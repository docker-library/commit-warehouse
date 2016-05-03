FROM ubuntu:14.04

MAINTAINER Guillaume Rosinosky <guillaume.rosinosky@bonitasoft.com>

ENV BONITA_VERSION 7.2.3
ENV PERF_REFPATH /opt/PerfLauncher
ENV PERF_MODE unitrunner
ENV PERF_TESTS standardProcess;messageStartProcess;messageSynchronizationProcess
ENV PERF_RESULTS_DIRECTORY /opt/results
ENV PERF_SERVER_MODE false
# avoid debconf messages
ENV DEBIAN_FRONTEND noninteractive
ENV PERF_TOOL_ARCHIVE_FILE PerfLauncher-bonitaBPM6-community-server-${BONITA_VERSION}-1.0-SNAPSHOT-postgres.zip
# install packages
RUN apt-get update && apt-get install -y \
  openjdk-7-jre-headless \
  unzip \
  wget \
  gettext \
  && rm -rf /var/lib/apt/lists/*

COPY startup.sh /opt/startup.sh
COPY config /opt/config
COPY bin/${PERF_TOOL_ARCHIVE_FILE} /opt/PerfLauncher.zip
RUN unzip /opt/PerfLauncher.zip -d /opt/PerfLauncher
# command to run when container starts
EXPOSE 61616
CMD /opt/startup.sh

