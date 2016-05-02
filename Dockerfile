FROM debian:jessie-backports

MAINTAINER Miguel Moquillon "miguel.moquillon@silverpeas.org"

ARG SILVERPEAS_VERSION=6.0-alpha1
ARG WILDFLY_VERSION=10.0.0
ARG DEFAULT_LOCALE=en_US.UTF-8

LABEL name="Silverpeas 6" description="Image to install and to run Silverpeas 6" vendor="Silverpeas" version=${SILVERPEAS_VERSION} build=1

#
# Check Silvereas and Wildfly at the asked version exist
#

RUN echo -n "Check build argument SILVERPEAS_VERSION: " && echo ${SILVERPEAS_VERSION} && test ! -z ${SILVERPEAS_VERSION}
RUN echo -n "Check build argument WILDFLY_VERSION: " && echo ${WILDFLY_VERSION} && test ! -z ${WILDFLY_VERSION}

RUN apt-get update && apt-get install -y wget

RUN wget --spider https://www.silverpeas.org/files/silverpeas-${SILVERPEAS_VERSION}-wildfly${WILDFLY_VERSION%.?.?}.zip \
  && wget --spider https://www.silverpeas.org/files/wildfly-${WILDFLY_VERSION}.Final.zip

#
# Install required and recommended programs for Silverpeas
#

# Installation of OpenJDK 8, ImageMagick, Ghostscript, LibreOffice, and then
# the dependencies required to build SWFTools and PDF2JSON
RUN apt-get update && apt-get install -y \
    locales \
    zip \
    unzip \
    openjdk-8-jdk \ 
    build-essential \
    autoconf \
    zlib1g-dev \
    libjpeg-dev \
    libfreetype6-dev \
    imagemagick \
    ghostscript \
    libreoffice \
    ure \
    gpgv \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
  && update-ca-certificates -f

# Fetch the last stable version of SWFTools, build it and install it
RUN wget -nc http://www.swftools.org/swftools-0.9.2.tar.gz \
  && tar zxvf swftools-0.9.2.tar.gz \
  && cd swftools-0.9.2 \
  && ./configure \
  && sed -i -e 's/rm -f $(pkgdatadir)\/swfs\/default_viewer.swf -o -L $(pkgdatadir)\/swfs\/default_viewer.swf/# rm -f $(pkgdatadir)\/swfs\/default_viewer.swf -o -L $(pkgdatadir)\/swfs\/default_viewer.swf/g' swfs/Makefile \
  && sed -i -e 's/rm -f $(pkgdatadir)\/swfs\/default_loader.swf -o -L $(pkgdatadir)\/swfs\/default_loader.swf/# rm -f $(pkgdatadir)\/swfs\/default_loader.swf -o -L $(pkgdatadir)\/swfs\/default_loader.swf/g' swfs/Makefile \
  && make && make install \
  && cd .. \
  && rm -rf swftools-0.9.2*

# Fetch the last stable version of PDF2JSON, build it and install it
RUN wget -nc https://github.com/flexpaper/pdf2json/releases/download/v0.68/pdf2json-0.68.tar.gz \
  && mkdir pdf2json \
  && tar zxvf pdf2json-0.68.tar.gz -C pdf2json \
  && cd pdf2json \
  && ./configure \
  && make && make install \
  && cd .. \
  && rm -rf pdf2json*

#
# Set up environment to install and to run Silverpeas
#

# Generate locales and set the default one
RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
  && echo "fr_FR.UTF-8 UTF-8" >> /etc/locale.gen \
  && echo "de_DE.UTF-8 UTF-8" >> /etc/locale.gen \
  && locale-gen \
  && update-locale LANG=${DEFAULT_LOCALE} LANGUAGE=${DEFAULT_LOCALE} LC_ALL=${DEFAULT_LOCALE}

ENV LANG ${DEFAULT_LOCALE}
ENV LANGUAGE ${DEFAULT_LOCALE}
ENV LC_ALL ${DEFAULT_LOCALE}

# Set up environment variables for Silverpeas
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64
ENV SILVERPEAS_HOME /opt/silverpeas
ENV JBOSS_HOME /opt/wildfly

#
# Install Silverpeas and Wildfly
#

# Fetch both Silverpeas and Wildfly and unpack them into /opt
RUN wget -nc https://www.silverpeas.org/files/silverpeas-${SILVERPEAS_VERSION}-wildfly${WILDFLY_VERSION%.?.?}.zip \
  && wget -nc https://www.silverpeas.org/files/silverpeas-${SILVERPEAS_VERSION}-wildfly${WILDFLY_VERSION%.?.?}.zip.asc \
  && gpg --keyserver hkp://pgp.mit.edu --recv-keys 3DF442B6 \
  && gpg --batch --verify silverpeas-${SILVERPEAS_VERSION}-wildfly${WILDFLY_VERSION%.?.?}.zip.asc silverpeas-${SILVERPEAS_VERSION}-wildfly${WILDFLY_VERSION%.?.?}.zip \
  && wget -nc http://download.jboss.org/wildfly/${WILDFLY_VERSION}.Final/wildfly-${WILDFLY_VERSION}.Final.zip \
  && unzip silverpeas-${SILVERPEAS_VERSION}-wildfly${WILDFLY_VERSION%.?.?}.zip -d /opt \
  && unzip wildfly-${WILDFLY_VERSION}.Final.zip -d /opt \
  && mv /opt/silverpeas-${SILVERPEAS_VERSION}-wildfly${WILDFLY_VERSION%.?.?} /opt/silverpeas \
  && mv /opt/wildfly-${WILDFLY_VERSION}.Final /opt/wildfly \
  && rm *.zip \
  && mkdir -p ${HOME}/.m2 \

# Copy the Maven settings.xml required to install Silverpeas by fetching the software bundles from 
# the Silverpeas Nexus Repository
COPY src/settings.xml ${HOME}/.m2/

# Set the default working directory
WORKDIR ${SILVERPEAS_HOME}/bin

# Copy this container init script that will be run each time the container is ran
COPY src/run.sh /opt/
COPY src/ooserver /opt/

# Assemble the Silverpeas application with its working directories and marks it as ready to complete
# the installation of Silverpeas in Wildfly at first run
RUN ./silverpeas assemble \
  && rm ../log/build-* \
  && touch .install

#
# Expose image entries. By default, when running, the container will set up Silverpeas and Wildfly
# according to the host environment.
#

# Silverpeas listens port 8000 by default
EXPOSE 8000 9990
# The following Silverpeas folders are exposed by default so that you can access the logs, the data, the properties
# or the configuration of Silverpeas outside the container
VOLUME ["/opt/silverpeas/log", "/opt/silverpeas/data", "/opt/silverpeas/properties", "/opt/silverpeas/configuration"]
CMD ["/opt/run.sh"]
