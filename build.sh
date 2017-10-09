#!/bin/bash
set -e

if [ "$#" -lt 1 ]
then
    SCRIPT_NAME=`basename "$0"`
    echo "Usage: $SCRIPT_NAME <Path_to_Dockerfile> [docker_build_args]"
    echo ""
    echo "Examples:"
    echo "  $> $SCRIPT_NAME bonita/7.5"
    echo "  $> $SCRIPT_NAME bonita-perf-tool/7.5"
    echo "  $> $SCRIPT_NAME bonita-subscription/7.5 --build-arg ORACLE_BASE_URL=https://jenkins.cloud.bonitasoft.com/userContent/resources"
    echo ""
    echo "Example with wget credentials:"
    echo "  $> $SCRIPT_NAME bonita-subscription/7.5 \\"
    echo "       '--build-arg BASE_URL=\"--user=adam --password=secretA https://repositories.cloud.bonitasoft.com/bonita-folder\" \\"
    echo "        --build-arg ORACLE_BASE_URL=\"--user=bob --password=secretB https://repositories.cloud.bonitasoft.com/oracle-folder\"'"
    exit 1
fi

BUILD_PATH=$1
shift
DOCKER_BUILD_ARGS="$*"

if [ ! -f "${BUILD_PATH}/Dockerfile" ]
then
    echo "File not found: <${BUILD_PATH}/Dockerfile>"
    exit 1
fi

BONITA_VERSION=$(grep -oP "^ENV BONITA_VERSION \K.*" "${BUILD_PATH}/Dockerfile" | sed 's/.*:-\(.*\)}$/\1/' | xargs)
FOLDER_NAME=$(basename $(dirname "${BUILD_PATH}"))
IMAGE_NAME=bonitasoft/${FOLDER_NAME}:${BONITA_VERSION}
ARCHIVE_NAME=${FOLDER_NAME}_${BONITA_VERSION}.tar.gz

echo ". Building image <${IMAGE_NAME}>"
build_cmd="docker build ${DOCKER_BUILD_ARGS} --no-cache=true -t ${IMAGE_NAME} ${BUILD_PATH}"
eval $build_cmd

echo ". Saving image to archive file <${ARCHIVE_NAME}>"
docker save ${IMAGE_NAME} | gzip > ${ARCHIVE_NAME}

echo ". Done!"

