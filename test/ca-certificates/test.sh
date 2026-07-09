#!/usr/bin/env bash

set -e

# Import 'check' command
source dev-container-features-test-lib

no_op() {
    echo "No operation"
}

check "ca-certificates no op" no_op

reportResults
