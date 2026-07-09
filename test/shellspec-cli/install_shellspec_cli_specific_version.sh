#!/usr/bin/env bash

set -e

source dev-container-features-test-lib

check "shellspec version is equal to 0.28.0" sh -c "shellspec --version | grep '0.28.0'"

reportResults
