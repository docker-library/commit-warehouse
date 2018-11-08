# Creates an image to build the CRUX filesystem

# TODO: Once bootstrapped, use 'crux:latest'
FROM alpine:3.8

RUN apk add --no-cache curl bash xz

COPY buildenv /buildenv
WORKDIR /buildenv

CMD ["./build"]
