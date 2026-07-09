#!/usr/bin/env bash

set -e

source dev-container-features-test-lib

check "cf version is equal to 8.14.1" sh -c "cf version | grep '8.14.1'"

reportResults
