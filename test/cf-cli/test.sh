#!/usr/bin/env bash

set -e

source dev-container-features-test-lib

check "cf version" cf version

reportResults
