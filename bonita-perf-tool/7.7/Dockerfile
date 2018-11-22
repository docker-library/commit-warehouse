FROM ubuntu:16.04

MAINTAINER Guillaume Rosinosky <guillaume.rosinosky@bonitasoft.com>

ARG BASE_URL
ARG BONITA_VERSION

ENV BONITA_VERSION ${BONITA_VERSION:-7.7.5}
ENV PERF_REFPATH /opt/PerfLauncher
ENV PERF_MODE unitrunner
ENV PERF_TESTS standardProcess;messageStartProcess;messageSynchronizationProcess
ENV PERF_RESULTS_DIRECTORY /opt/results
ENV PERF_SERVER_MODE false
ENV PERF_TOOL_ARCHIVE_FILE PerfLauncher-bonitaBPM6-sp-client-${BONITA_VERSION}-1.0-SNAPSHOT-postgres.zip
ENV BASE_URL ${BASE_URL:-http://repositories.rd.lan/nas/releases/performance_tools/}

# avoid debconf messages
ENV DEBIAN_FRONTEND noninteractive

# install packages
RUN apt-get update && apt-get install -y \
  openjdk-8-jre-headless \
  unzip \
  curl \
  gettext \
  && rm -rf /var/lib/apt/lists/*

COPY startup.sh /opt/startup.sh
COPY config /opt/config

RUN curl -fsSL ${BASE_URL}/${PERF_TOOL_ARCHIVE_FILE} -o /opt/PerfLauncher.zip \
  && unzip /opt/PerfLauncher.zip -d /opt/PerfLauncher

# command to run when container starts
EXPOSE 61616
CMD /opt/startup.sh
