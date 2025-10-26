#!/usr/bin/env bash

set -e

source dev-container-features-test-lib

check "copilot version" copilot --version

reportResults
