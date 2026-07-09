#!/usr/bin/env bash

set -e

source dev-container-features-test-lib

check "specify version is equal to v0.0.19" sh -c "uv tool list | grep 'specify-cli v0.0.19'"

reportResults
