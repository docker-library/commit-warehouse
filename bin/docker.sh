#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

echo Building version $1
docker build -t rapidoid/rapidoid:$1 .
docker images -a
