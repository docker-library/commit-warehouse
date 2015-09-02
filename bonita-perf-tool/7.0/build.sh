#!/bin/bash
set -e

BONITA_VERSION=$(grep -oP "^ENV BONITA_VERSION \K.*" Dockerfile | xargs)
IMAGE_NAME=bonitasoft/bonita-perf-tool:${BONITA_VERSION}
TAR_NAME=bonita_bench_${BONITA_VERSION}.tar

PERF_TOOL_ARCHIVE_FILE=PerfLauncher-bonitaBPM6-community-server-${BONITA_VERSION}-1.0-SNAPSHOT-postgres.zip


if [[ -z "$@" ]]
then
    echo "Argument <base_url> is missing"
    echo "Expected location: <base_url>/${PERF_TOOL_ARCHIVE_FILE}"
else
    echo "Downloading $1/${PERF_TOOL_ARCHIVE_FILE}"
    rm -rf bin/PerfLauncher*
    wget $1/${PERF_TOOL_ARCHIVE_FILE} -O bin/${PERF_TOOL_ARCHIVE_FILE}

    echo ". Building image <${IMAGE_NAME}>"
    docker build -t ${IMAGE_NAME} .
    
    echo ". Saving image to archive file <${TAR_NAME}>"
    docker save ${IMAGE_NAME} > ${TAR_NAME}
    
    echo ". Done!"
fi

