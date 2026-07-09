#!/usr/bin/env bash

set -e

source dev-container-features-test-lib

check "kf version" kf version

reportResults
