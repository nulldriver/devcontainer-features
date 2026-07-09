#!/usr/bin/env bash

set -e

source dev-container-features-test-lib

check "credhub version is equal to 2.9.50" sh -c "credhub --version | grep '2.9.50'"

reportResults
