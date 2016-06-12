#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

echo Building version $1
sudo docker build -t rapidoid/rapidoid:$1 .
sudo docker images -a
