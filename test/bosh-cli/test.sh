#!/bin/bash

# This test can be run with the following command (from the root of this repo)
# devcontainer features test --features bosh-cli --base-image mcr.microsoft.com/devcontainers/base:ubuntu .

set -e

# Import 'check' command
source dev-container-features-test-lib

check "version" bosh --version

# Check that dependencies were installed
check "has ruby" ruby --version
check "has patch" patch --version

reportResults
