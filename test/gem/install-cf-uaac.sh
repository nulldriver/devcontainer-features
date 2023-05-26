#!/bin/bash

set -e

# Import 'check' command
source dev-container-features-test-lib

check "uaac" uaac version

reportResults
