FROM scratch
ADD amzn2-container-raw-2.0.20191016.0-x86_64.tar.xz /
CMD ["/bin/bash"]
RUN mkdir /usr/src/srpm \
 && curl -o /usr/src/srpm/srpm-bundle.tar.gz "https://amazon-linux-docker-sources.s3-accelerate.amazonaws.com/srpm-bundle-d1f7ba83a09507e3f28d42e6eee3353f48a35323e221ae085fdba23eecca6953.tar.gz" \
 && echo "5c2df0caf207a94a552d4b1197048ffea38366d6d74144ce73f9b555cfebedb5  /usr/src/srpm/srpm-bundle.tar.gz" | sha256sum -c -
