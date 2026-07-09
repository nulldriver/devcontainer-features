#!/usr/bin/env bash

set -e

source dev-container-features-test-lib

check "shellspec version" shellspec --version

reportResults
