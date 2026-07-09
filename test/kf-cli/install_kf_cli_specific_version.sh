#!/usr/bin/env bash

set -e

source dev-container-features-test-lib

check "kf version is equal to 2.11.28" sh -c "kf version | grep '2.11.28'"

reportResults
