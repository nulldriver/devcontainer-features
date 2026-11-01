#!/usr/bin/env bash

set -e

source dev-container-features-test-lib

check "credhub version" credhub --version
if [ -n "${EXPECTED_VERSION:-}" ]; then
    check "pinned credhub version" bash -c 'credhub --version | grep -F "$EXPECTED_VERSION"'
fi

case "$(dpkg --print-architecture)" in
    amd64) expected_machine=62 ;;
    arm64) expected_machine=183 ;;
esac
check "native credhub ELF architecture" test "$(od -An -tu2 -j18 -N2 "$(command -v credhub)" | tr -d ' ')" = "${expected_machine}"

reportResults
