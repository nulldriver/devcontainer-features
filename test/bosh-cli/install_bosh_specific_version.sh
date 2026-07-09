#!/usr/bin/env bash

set -e

source dev-container-features-test-lib

check "bosh version is equal to 7.9.12" sh -c "bosh --version | grep '7.9.12'"

reportResults
