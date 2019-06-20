# Set the base image
FROM openjdk:8-jdk

MAINTAINER Lightstreamer Server Development Team <support@lightstreamer.com>

# Import Lighstreamer's public key
RUN gpg --keyserver ha.pool.sks-keyservers.net --recv-keys 9B90BFD14309C7DA5EF58D7D4A8C08966F29B4D2

# Set environment variables to identify the right Lightstreamer version and edition
ENV LIGHSTREAMER_EDITION Allegro-Presto-Vivace
ENV LIGHSTREAMER_VERSION 6_0_3_20160905
ENV LIGHSTREAMER_URL_DOWNLOAD http://www.lightstreamer.com/repo/distros/Lightstreamer_${LIGHSTREAMER_EDITION}_${LIGHSTREAMER_VERSION}.tar.gz

# Set the temporary working dir
WORKDIR /lightstreamer

# Download the package from the Lightstreamer site and replace the fictitious jdk path with 
# the JAVA_HOME environment variable in the launch script file.
# Finally, adjust logging configuration to log only on standard output.
RUN set -x \
        && curl -fSL -o Lightstreamer.tar.gz ${LIGHSTREAMER_URL_DOWNLOAD} \
        && curl -fSL -o Lightstreamer.tar.gz.asc ${LIGHSTREAMER_URL_DOWNLOAD}.asc \
        && gpg --batch --verify Lightstreamer.tar.gz.asc Lightstreamer.tar.gz \
        && tar -xvf Lightstreamer.tar.gz --strip-components=1 \
        && rm Lightstreamer.tar.gz Lightstreamer.tar.gz.asc \
        && sed -i -- 's/\/usr\/jdk1.8.0/$JAVA_HOME/' bin/unix-like/LS.sh \
        && sed -i -e '123,$s/<appender-ref ref="LSDailyRolling" \/>/<appender-ref ref="LSConsole" \/>/' \
                  -e '/<appender-ref ref="LSDailyRolling" \/>/ d' conf/lightstreamer_log_conf.xml

# Export TCP port 8080
EXPOSE 8080

# Set the final working dir
WORKDIR /lightstreamer/bin/unix-like

# Start the server
CMD ["./LS.sh", "run"]
