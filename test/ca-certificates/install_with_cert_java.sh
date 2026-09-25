#!/usr/bin/env bash

set -e

# Import 'check' command
source dev-container-features-test-lib

check "cert file exists" test -f /usr/local/share/ca-certificates/custom-ca.crt

check "cert trusted in system bundle" grep -q "NP6HhF2PRKwP" /etc/ssl/certs/ca-certificates.crt

find_cacerts() {
    local keytool_path java_home
    keytool_path="$(readlink -f "$(command -v keytool)")"
    java_home="${JAVA_HOME:-$(dirname "$(dirname "${keytool_path}")")}"
    if [ -f "${java_home}/lib/security/cacerts" ]; then
        echo "${java_home}/lib/security/cacerts"
    else
        echo "${java_home}/jre/lib/security/cacerts"
    fi
}

check "keytool available" bash -c 'command -v keytool'

CACERTS="$(find_cacerts)"

check "cert imported into Java truststore" bash -c "keytool -list -keystore '${CACERTS}' -storepass changeit -alias custom-ca"

reportResults
