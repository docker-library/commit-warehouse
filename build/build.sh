#!/usr/bin/env bash

set -e

if [[ ! -f $MEDIA/$(basename ${URL}) ]]; then
    echo "Downloading ${URL} ..."
	curl -# -q -o $MEDIA/$(basename ${URL}) $URL
fi

echo "Creating Root FS ..."
./mkrootfs.sh $MEDIA/$(basename ${URL})
