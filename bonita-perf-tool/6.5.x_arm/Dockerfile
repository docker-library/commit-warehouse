FROM armbuild/ubuntu-debootstrap:trusty

MAINTAINER Guillaume Rosinosky <guillaume.rosinosky@bonitasoft.com>

ENV PERF_REFPATH /opt/PerfLauncher
ENV PERF_MODE unitrunner
ENV PERF_TESTS standardProcess;messageStartProcess;messageSynchronizationProcess
ENV PERF_RESULTS_DIRECTORY /opt/results
ENV PERF_SERVER_MODE false
# avoid debconf messages
ENV DEBIAN_FRONTEND noninteractive

# install packages
RUN apt-get update && apt-get install -y \
  openjdk-7-jre-headless \
  unzip \
  wget \
  gettext \
  && rm -rf /var/lib/apt/lists/*

#COPY PerfLauncher.zip /opt/PerfLauncher.zip
COPY PerfLauncher-bonitaBPM6-community-server-6.5.0-SNAPSHOT-1.0-SNAPSHOT-h2.zip /opt/PerfLauncher.zip
COPY startup.sh /opt/startup.sh
COPY config /opt/config
RUN unzip /opt/PerfLauncher.zip -d /opt/PerfLauncher
# command to run when container starts
EXPOSE 61616
CMD /opt/startup.sh

