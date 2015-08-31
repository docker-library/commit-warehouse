#!/usr/bin/env bash

set -e

if [[ ! -f /mnt/media/$(basename ${URL}) ]]; then
    echo "Downloading ${URL} ..."
	curl -# -q -o /mnt/media/$(basename ${URL}) $URL
fi

echo "Creating Root FS ..."
./mkrootfs.sh /mnt/media/$(basename ${URL})
