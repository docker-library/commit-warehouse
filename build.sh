#!/bin/bash

set -e

print_error() {
  RED='\033[0;31m'
  NC='\033[0m' # No Color
  printf "${RED}ERROR - $1\n${NC}"
}

exit_with_usage() {
  SCRIPT_NAME=`basename "$0"`
  [ ! -z "$1" ] && print_error "$1" >&2
  echo ""
  echo "Usage: ./$SCRIPT_NAME [options] -- <Path_to_Dockerfile> [--build-arg key=value]"
  echo ""
  echo "Options:"
  echo "  -f docker_build_args_file  file to read docker build arguments from"
  echo "  -c                         use Docker cache while building image - by default build is performed with '--no-cache=true'"
  echo ""
  echo "Examples:"
  echo "  $> ./$SCRIPT_NAME -- bonita/7.5"
  echo "  $> ./$SCRIPT_NAME -- bonita-perf-tool/7.5 --build-arg key1=value1 --build-arg key2=value2"
  echo "  $> ./$SCRIPT_NAME -f build_args -- bonita-subscription/7.5"
  echo "  $> ./$SCRIPT_NAME -f build_args -c -- bonita-subscription/7.5 --build-arg key1=value1 --build-arg key2=value2"
  echo ""
  echo "Sample docker_build_args_file:"
  echo "BASE_URL=https://repositories.cloud.bonitasoft.com/repository/s3-raw/bonita"
  echo "ORACLE_BASE_URL=\"-u alice:secretA https://repositories.cloud.bonitasoft.com/repository/s3-raw/oracle\""
  exit 1
}

# parse command line arguments
no_cache="true"
while [ "$#" -gt 0 ]
do
  # process next argument
  case $1 in
    -a)
      shift
      BUILD_ARGS_FILE=$1
      if [ -z "$BUILD_ARGS_FILE" ]
      then
        exit_with_usage "Option -a requires an argument."
      fi
      if [ ! -f "$BUILD_ARGS_FILE" ]
      then
        exit_with_usage "Build args file not found: $BUILD_ARGS_FILE"
      fi
      ;;
    -c)
      no_cache="false"
      ;;
    --)
      shift
      break
      ;;
    *)
      exit_with_usage "Unrecognized option: $1"
      ;;
  esac
  if [ "$#" -gt 0 ]
  then
    shift
  fi
done

if [ "$#" -lt 1 ]
then
    exit_with_usage
fi


BUILD_PATH=$1
shift
BUILD_ARGS="--no-cache=${no_cache}"

# validate build path
if [ -z "${BUILD_PATH}" ]
then
  exit_with_usage
fi
if [ ! -f "${BUILD_PATH}/Dockerfile" ]
then
  exit_with_usage "File not found: ${BUILD_PATH}/Dockerfile"
fi

# append build args found in docker_build_args_file
if [ ! -z "$BUILD_ARGS_FILE" ] && [ ! -f "$BUILD_ARGS_FILE" ]
then
  exit_with_usage "Build args file not found: $BUILD_ARGS_FILE"
fi
if [ ! -z "$BUILD_ARGS_FILE" ] && [ -f "$BUILD_ARGS_FILE" ]
then
  BUILD_ARGS="$BUILD_ARGS $(echo $(cat $BUILD_ARGS_FILE | sed 's/^/--build-arg /g'))"
fi

# append build args found on command line
BUILD_ARGS="$BUILD_ARGS $*"

BONITA_VERSION=$(grep -oP "^ENV BONITA_VERSION \K.*" "${BUILD_PATH}/Dockerfile" | sed 's/.*:-\(.*\)}$/\1/' | xargs)
FOLDER_NAME=$(basename $(dirname "${BUILD_PATH}"))
IMAGE_NAME=bonitasoft/${FOLDER_NAME}:${BONITA_VERSION}
ARCHIVE_NAME=${FOLDER_NAME}_${BONITA_VERSION}.tar.gz

echo ". Building image <${IMAGE_NAME}>"
echo "Docker build caching strategy: --no-cache=${no_cache}"
build_cmd="docker build ${BUILD_ARGS} -t ${IMAGE_NAME} ${BUILD_PATH}"
eval $build_cmd

echo ". Saving image to archive file <${ARCHIVE_NAME}>"
docker save ${IMAGE_NAME} | gzip > ${ARCHIVE_NAME}

echo ". Done!"
