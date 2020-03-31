FROM scratch
ADD amzn2-container-raw-2.0.20200304.0-arm64.tar.xz /
CMD ["/bin/bash"]
RUN mkdir /usr/src/srpm \
 && curl -o /usr/src/srpm/srpm-bundle.tar.gz "https://amazon-linux-docker-sources.s3-accelerate.amazonaws.com/srpm-bundle-4cda1b0d98865d12f61886af2ff052cf2cb4a48734bded0ac84d2664a0361220.tar.gz" \
 && echo "c53ef45b008bcb392f9ecbd229a6fa38f69cfe536d630560a8e1a8daaa8b68e6  /usr/src/srpm/srpm-bundle.tar.gz" | sha256sum -c -
