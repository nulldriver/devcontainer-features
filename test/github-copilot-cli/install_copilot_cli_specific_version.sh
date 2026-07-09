#!/usr/bin/env bash

set -e

source dev-container-features-test-lib

check "copilot version is equal to 0.0.350" sh -c "copilot --version | grep '0.0.350'"

reportResults
