#!/usr/bin/env bash

set -e

source dev-container-features-test-lib

# todo: determine how to check a specific url was used
check "fly version" fly --version

reportResults
