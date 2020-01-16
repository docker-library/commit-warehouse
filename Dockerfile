FROM scratch
ADD amzn-container-minimal-2018.03.0.20191219.0-x86_64.tar.xz /
CMD ["/bin/bash"]
RUN mkdir /usr/src/srpm \
 && curl -o /usr/src/srpm/srpm-bundle.tar.gz "https://amazon-linux-docker-sources.s3-accelerate.amazonaws.com/srpm-bundle-82765bec2ec6aa88fb87dde775c5976db55c2a6f0aeb32fcaaffef420ff75f25.tar.gz" \
 && echo "2a02207625adf2733571c14cf68bdac4e3d4a481f14620b398c368e14bf0c432  /usr/src/srpm/srpm-bundle.tar.gz" | sha256sum -c -
