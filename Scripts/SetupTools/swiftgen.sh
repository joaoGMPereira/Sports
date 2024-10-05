#!/bin/bash
set -euo pipefail

SWIFTGEN_FILE=swiftgen.rb

uninstallCurrentVersion() {
    brew unpin swiftgen
    brew uninstall swiftgen
    brew update
}

installVersion() {
    brew install swiftgen

    brew pin swiftgen
}

verifyIfPackageIsInstalled() {
    if brew ls --versions swiftgen > /dev/null; then
        echo "swiftgen package found"
        uninstallCurrentVersion
        installVersion
    else
        echo "swiftgen package not found, installing..."
        installVersion
    fi
}

verifyIfPackageIsInstalled
