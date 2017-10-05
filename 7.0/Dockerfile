# Set the base image
FROM openjdk:8-jre-alpine

LABEL maintainer="Lightstreamer Server Development Team <support@lightstreamer.com>"

# Set environment variables to identify the right Lightstreamer version
ENV LIGHSTREAMER_VERSION 7_0_0_b1_20170704
ENV LIGHSTREAMER_URL_DOWNLOAD http://www.lightstreamer.com/repo/distros/Lightstreamer_${LIGHSTREAMER_VERSION}.tar.gz

# Set the temporary working dir
WORKDIR /lightstreamer

# Finally, adjust logging configuration to log only on standard output.
RUN set -x \
       apk add update \


# Install required packages
        && apk add --no-cache --virtual .fetch-deps \
                gnupg \
                tar \
                openssl \
# Import Lighstreamer's public key (it seems that current gpg version has an issue while contacting keyserver, therefore a workaround is required)
        && wget "https://ha.pool.sks-keyservers.net/pks/lookup?op=get&search=0x4A8C08966F29B4D2" -O - | gpg --import \

# Download the package from the Lightstreamer site and replace the fictitious jdk path with 
# the JAVA_HOME environment variable in the launch script file.

        && wget -O Lightstreamer.tar.gz ${LIGHSTREAMER_URL_DOWNLOAD} \
        && wget -O Lightstreamer.tar.gz.asc ${LIGHSTREAMER_URL_DOWNLOAD}.asc \
        && gpg --batch --verify Lightstreamer.tar.gz.asc Lightstreamer.tar.gz \
        && tar -xvf Lightstreamer.tar.gz --strip-components=1 \
        && rm Lightstreamer.tar.gz Lightstreamer.tar.gz.asc \
        && sed -i -- 's/\/usr\/jdk1.8.0/$JAVA_HOME/' bin/unix-like/LS.sh \
        && sed -i -e '123,$s/<appender-ref ref="LSDailyRolling" \/>/<appender-ref ref="LSConsole" \/>/' \
                  -e '/<appender-ref ref="LSDailyRolling" \/>/ d' conf/lightstreamer_log_conf.xml \
        && apk del gnupg tar openssl

# Export TCP port 8080
EXPOSE 8080

# Set the final working dir
WORKDIR /lightstreamer/bin/unix-like

# Start the server
CMD ["./LS.sh", "run"]
