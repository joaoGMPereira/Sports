#!/bin/sh
if [ -n "${IS_PROD_TARGET}" ] || [ -n "${IS_HOMOLOG_TARGET}" ]; then
    REPOSITORY_PATH="${BITRISE_SOURCE_DIR}"
else
    REPOSITORY_PATH="$(git rev-parse --show-toplevel)"
fi
export IOS_DEPLOY_TARGET="17.0"
export IOS_TESTS_DEPLOY_TARGET="17.0"
export IOS_TESTS_SWIFT_VERSION="6.0"
export IOS_TESTS_PARALLELIZABLE=false
export SWIFTGEN_SH_PATH="${REPOSITORY_PATH}/Scripts/SwiftGen.sh"
