#!/bin/bash
set -e

if [ "$#" -ne 1 ]
then
    SCRIPT_NAME=`basename "$0"`
    echo "Usage: $SCRIPT_NAME <Path_to_Dockerfile>"
    echo ""
    echo "Examples:"
    echo "  $> $SCRIPT_NAME bonita/7.0"
    echo "  $> $SCRIPT_NAME bonita-perf-tool/7.0"
    echo "  $> $SCRIPT_NAME bonita-performance/7.0"
    exit 1
fi

BUILD_PATH=$1

if [ ! -f "${BUILD_PATH}/Dockerfile" ]
then
    echo "File not found: <${BUILD_PATH}/Dockerfile>"
    exit 1
fi

BONITA_VERSION=$(grep -oP "^ENV BONITA_VERSION \K.*" "${BUILD_PATH}/Dockerfile" | sed 's/.*:-\(.*\)}$/\1/' | xargs)
FOLDER_NAME=$(basename $(dirname "${BUILD_PATH}"))
IMAGE_NAME=bonitasoft/${FOLDER_NAME}:${BONITA_VERSION}
TAR_NAME=${FOLDER_NAME}_${BONITA_VERSION}.tar

echo ". Building image <${IMAGE_NAME}>"
docker build --no-cache=true -t ${IMAGE_NAME} "${BUILD_PATH}"

echo ". Saving image to archive file <${TAR_NAME}>"
docker save ${IMAGE_NAME} > ${TAR_NAME}

echo ". Done!"

