#!/usr/bin/env bash

set -e

source dev-container-features-test-lib

no_op() {
    echo "No operation"
}

check "gem no op" no_op

reportResults
