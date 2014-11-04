#!/usr/bin/env bash

set -e

if [[ ! -f $MEDIA/$NAME-$VERSION.iso ]]; then
    echo "Downloading ISO ..."
    cd $MEDIA && curl -# -q -O $URL/$NAME-$VERSION/iso/$NAME-$VERSION.iso
fi

echo "Creating Root FS ..."
sudo ./mkrootfs.sh $MEDIA/$NAME-$VERSION.iso
