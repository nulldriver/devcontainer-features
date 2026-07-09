#!/usr/bin/env bash

set -e

# Import 'check' command
source dev-container-features-test-lib

check "no cert file installed" bash -c '[ ! -f /usr/local/share/ca-certificates/custom-ca.crt ]'

check "NODE_EXTRA_CA_CERTS not set" bash -lc '[ -z "${NODE_EXTRA_CA_CERTS:-}" ]'

reportResults
