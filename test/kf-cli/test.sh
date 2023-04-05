#!/bin/bash

# This test can be run with the following command (from the root of this repo)
# devcontainer features test --features kf-cli --base-image mcr.microsoft.com/devcontainers/base:ubuntu .

set -e

# Import 'check' command
source dev-container-features-test-lib

check "version" kf version

reportResults
