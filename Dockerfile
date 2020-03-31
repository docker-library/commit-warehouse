FROM scratch
ADD amzn-container-minimal-2018.03.0.20200318.1-x86_64.tar.xz /
CMD ["/bin/bash"]
RUN mkdir /usr/src/srpm \
 && curl -o /usr/src/srpm/srpm-bundle.tar.gz "https://amazon-linux-docker-sources.s3-accelerate.amazonaws.com/srpm-bundle-1f39c46b9f2dee01a647e53170c3c40bed489f7f522519d33d00c5e082eda17a.tar.gz" \
 && echo "4c7e33ec81dd7b7e9ed483bd8da66073d5d891b96d0836ccbf0e78946014e6f9  /usr/src/srpm/srpm-bundle.tar.gz" | sha256sum -c -
