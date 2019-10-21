FROM scratch
ADD amzn-container-minimal-2018.03.0.20191014.0-x86_64.tar.xz /
CMD ["/bin/bash"]
RUN mkdir /usr/src/srpm \
 && curl -o /usr/src/srpm/srpm-bundle.tar.gz "https://amazon-linux-docker-sources.s3-accelerate.amazonaws.com/srpm-bundle-856bb2f81dfb6dae1bc33b3c3d55b30c990037ccc6da70f3e10ae7f6c13cf841.tar.gz" \
 && echo "e1f981f4d077e2f832d9a9e5a8e34dd9f16ced8725a897d90b3dcf79799481f9  /usr/src/srpm/srpm-bundle.tar.gz" | sha256sum -c -
