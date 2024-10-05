#!/bin/sh

source Scripts/envVariables.sh

echo "\nGenerating project"

xcodegen -q -s project.yml

echo "Done."
