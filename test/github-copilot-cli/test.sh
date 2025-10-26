#!/usr/bin/env bash

set -e

source dev-container-features-test-lib

no_op() {
    echo "scenarios.json is used for tests to ensure proper base image configuration"
}

check "empty test" no_op

reportResults
