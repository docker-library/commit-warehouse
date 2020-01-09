FROM scratch
ADD amzn2-container-raw-2.0.20191217.0-x86_64.tar.xz /
CMD ["/bin/bash"]
RUN mkdir /usr/src/srpm \
 && curl -o /usr/src/srpm/srpm-bundle.tar.gz "https://amazon-linux-docker-sources.s3-accelerate.amazonaws.com/srpm-bundle-ecb5177bc6769961844d6bbc8632ca9f4326737db8dba1aae6875d6021507dfa.tar.gz" \
 && echo "5bc97d65c81fdc544a92c8b1bd8ccc56b730c4354e0fc9b4529e147056eef82d  /usr/src/srpm/srpm-bundle.tar.gz" | sha256sum -c -
