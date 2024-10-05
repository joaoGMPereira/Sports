#!/bin/sh
set -euo pipefail

installSpecificBundlerVersion() {
    local GEMFILE_PATH=Gemfile.lock
    local GEM_BUNDLER_VERSION=$(grep -A1 -E -i -w '(BUNDLED WITH){1,1}' ${GEMFILE_PATH} | grep -E -i -w "[0-9\.]{1,}" | xargs)
    local CURRENT_BUNDLER_VERSION=$(bundle --version | grep -o -E -i -w "[0-9\.]{1,}" | xargs)
    if [[ -f "${GEMFILE_PATH}" ]]; then
    echo "Found Gemfile"
        if [[ $GEM_BUNDLER_VERSION != $CURRENT_BUNDLER_VERSION ]]; then
            echo "Gemfile expected version: ${GEM_BUNDLER_VERSION}"
            echo "Current reported version: ${CURRENT_BUNDLER_VERSION}"

            echo "Installing bundler, version ${GEM_BUNDLER_VERSION}"
            gem install bundler -v=$GEM_BUNDLER_VERSION --force

            echo "Updated bundler to version: ${GEM_BUNDLER_VERSION}"
        else
            echo "Current Bundler [$(bundle --version)] follows Gemfile [${GEM_BUNDLER_VERSION}]"
        fi
        bundle install
    else
        echo "No Gemfile to match version."
    fi
}

installSpecificBundlerVersion