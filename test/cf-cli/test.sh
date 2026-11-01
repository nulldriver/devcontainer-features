#!/usr/bin/env bash

set -e

source dev-container-features-test-lib

check "cf version" cf version
if [ -n "${EXPECTED_VERSION:-}" ]; then
    check "pinned cf version" bash -c 'cf version | grep -F "$EXPECTED_VERSION"'
fi

case "$(dpkg --print-architecture)" in
    amd64) expected_machine=62 ;;
    arm64) expected_machine=183 ;;
esac
check "native cf ELF architecture" test "$(od -An -tu2 -j18 -N2 "$(command -v cf)" | tr -d ' ')" = "${expected_machine}"

reportResults
