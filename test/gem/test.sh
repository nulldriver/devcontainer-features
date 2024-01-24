#!/bin/bash

set -e

# This test can be run with the following command (from the root of this repo)
# devcontainer features test --features gem --base-image mcr.microsoft.com/devcontainers/base:ubuntu .

# Import 'check' command
source dev-container-features-test-lib

# Feature-specific tests
no_op() {
    echo "gem tests use scenarios.json instead so that we can specify using the ruby image"
}

check "empty test" no_op

reportResults
