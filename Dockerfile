FROM scratch
ADD amzn2-container-raw-2.0.20200406.0-x86_64.tar.xz /
CMD ["/bin/bash"]
RUN mkdir /usr/src/srpm \
 && curl -o /usr/src/srpm/srpm-bundle.tar.gz "https://amazon-linux-docker-sources.s3-accelerate.amazonaws.com/srpm-bundle-44ab891c498d922bb21e90b6006b12c7f05381ec7e67aba05bb535aae3b261b1.tar.gz" \
 && echo "a1b70378c6175331c9daa5bee79c8cb36dab14ed1fb0d02bfd33254652f0b846  /usr/src/srpm/srpm-bundle.tar.gz" | sha256sum -c -
