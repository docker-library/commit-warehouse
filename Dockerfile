FROM scratch
ADD amzn2-container-raw-2.0.20200207.1-arm64.tar.xz /
CMD ["/bin/bash"]
RUN mkdir /usr/src/srpm \
 && curl -o /usr/src/srpm/srpm-bundle.tar.gz "https://amazon-linux-docker-sources.s3-accelerate.amazonaws.com/srpm-bundle-9d577ed8f0e2cbd076b6f144ec0c470c9c81012109b3d19515b8287114f96859.tar.gz" \
 && echo "88b2385d08e0f3df72a3d6b411c6b418af927ef411549cea48a3dfd887bf0f29  /usr/src/srpm/srpm-bundle.tar.gz" | sha256sum -c -
