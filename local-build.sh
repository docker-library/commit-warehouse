#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

echo Building tag $1
docker build -t rapidoid/rapidoid:$1 .
docker images -a
