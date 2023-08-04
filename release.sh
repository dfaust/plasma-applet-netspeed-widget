#!/bin/env bash

if [ -e "netspeed-widget-$1.plasmoid" ]; then
    echo "File \`netspeed-widget-$1.plasmoid\` alread exists"
    exit
fi

pushd package

zip -r ../netspeed-widget-$1.plasmoid *

popd
