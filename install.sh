#!/bin/env bash

mkdir --parents --verbose ~/.local/share/plasma/plasmoids/org.kde.netspeedWidget
cp --recursive --update --verbose ./package/* $_
