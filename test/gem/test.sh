#!/bin/bash

set -e

# Import 'check' command
source dev-container-features-test-lib

# Feature-specific tests
no_op() {
    echo "gem tests use scenarios.json instead so that we can specify using the ruby image"
}

check "empty test" no_op

reportResults
