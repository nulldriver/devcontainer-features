#!/usr/bin/env bash

set -e

source dev-container-features-test-lib

# todo: determine how to check a specific version was specified (builder does not have a version flag)
check "builder help" builder --help

reportResults
