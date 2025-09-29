#!/bin/bash

# This test can be run with the following command (from the root of this repo)
# devcontainer features test --features specify-cli --base-image mcr.microsoft.com/devcontainers/base:ubuntu .

set -e

# Import 'check' command
source dev-container-features-test-lib

# Test that specify command is available
check "specify command available" command -v specify

# Test that specify can show help/version
check "specify help" specify --help

# Test that specify check command works
check "specify check" specify check

reportResults
