#!/usr/bin/env bash

set -e

source dev-container-features-test-lib

check "bosh version" bosh --version

# Check that dependencies were installed
check "has ruby" ruby --version
check "has sqlite3" sqlite3 --version

reportResults
