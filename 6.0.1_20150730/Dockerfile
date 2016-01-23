# Set the base image
FROM java:openjdk-8-jdk

MAINTAINER Lightstreamer Server Development Team <support@lightreamer.com>

# Set environment variables to identify the right Lightstreamer version and edition
ENV LIGHSTREAMER_EDITION Allegro-Presto-Vivace
ENV LIGHSTREAMER_VERSION 6_0_1_20150730
ENV LIGHSTREAMER_URL_DOWNLOAD http://www.lightstreamer.com/repo/distros/Lightstreamer_${LIGHSTREAMER_EDITION}_${LIGHSTREAMER_VERSION}.tar.gz

# Set the temporary working dir
WORKDIR /lightstreamer

# Download the package from the Lightstreamer site and replace the fictitious jdk path with the JAVA_HOME environment variable in the launch script file.
RUN set -x \
        && curl -fSL -o Lightstreamer.tar.gz ${LIGHSTREAMER_URL_DOWNLOAD} \
        && tar -xvf Lightstreamer.tar.gz --strip-components=1 \
        && rm Lightstreamer.tar.gz \
        && sed -i -- 's/\/usr\/jdk1.7.0/$JAVA_HOME/' bin/unix-like/LS.sh

# Export TCP port 8080
EXPOSE 8080

# Set the final working dir
WORKDIR /lightstreamer/bin/unix-like

# Define the entry point
ENTRYPOINT ["./LS.sh", "run"]
