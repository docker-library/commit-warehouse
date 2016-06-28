#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

echo "Testing Rapidoid (version $1)"
ID=$(docker run -d --net=host rapidoid/rapidoid:$1)
echo $ID

for i in $(seq 1 5); do
  curl -s 'http://localhost:8888/' >> /dev/null || sleep 1
done

curl -s 'http://localhost:8888/' | grep -c "Welcome to Rapidoid" || exit 1
curl -s 'http://localhost:8888/_' | grep -c "username" || exit 1
curl -s 'http://localhost:8888/_' | grep -c "password" || exit 1

docker stop $ID
docker rm $ID

echo OK
