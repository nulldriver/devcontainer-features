#!/usr/bin/env bash

set -e

source dev-container-features-test-lib

check "specify help" specify --help

reportResults
