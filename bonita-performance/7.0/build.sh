#!/bin/bash

BONITA_VERSION=$(grep -oP "^ENV BONITA_VERSION \K.*" Dockerfile | xargs)
IMAGE_NAME=bonitasoft/bonita-performance:${BONITA_VERSION}
TAR_NAME=bonita_performance_${BONITA_VERSION}.tar

echo ". Building image <${IMAGE_NAME}>"
docker build -t ${IMAGE_NAME} .

echo ". Saving image to archive file <${TAR_NAME}>"
docker save ${IMAGE_NAME} > ${TAR_NAME}

echo ". Done!"
