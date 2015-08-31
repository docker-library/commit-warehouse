#!/usr/bin/env bash

set -e

if [[ ! -f $MEDIA/$(basename ${URL}) ]]; then
    echo "Downloading ISO ..."
    cd $MEDIA && curl -# -q -O $URL
fi

echo "Creating Root FS ..."
./mkrootfs.sh $MEDIA/$(basename ${URL})
