#!/bin/bash
# Verify that disabling environment exports also disables deferred Java imports.

set -e

# shellcheck source=/dev/null
source dev-container-features-test-lib

check "cert file exists" \
  test -f /usr/local/share/ca-certificates/custom-ca.crt
check "cert trusted in system bundle" \
  grep -q "NP6HhF2PRKwP" /etc/ssl/certs/ca-certificates.crt
check "Java import disabled" \
  test ! -f /usr/local/share/ca-certificates-feature/java.conf
# Expand JAVA_HOME in the child shell.
# shellcheck disable=SC2016
check "Java alias absent" bash -c '
  ! keytool -list -keystore "${JAVA_HOME}/lib/security/cacerts" \
    -storepass changeit -alias custom-ca
'
# Check the child login shell's environment rather than this process's.
# shellcheck disable=SC2016
check "environment exports disabled" \
  bash -lc '[[ -z "${NODE_EXTRA_CA_CERTS:-}" ]]'
check "disabled helper succeeds" /usr/local/bin/import-java-certificates

reportResults
