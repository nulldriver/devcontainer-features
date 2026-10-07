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

check "certificate contents match" bash -c 'cmp <(openssl x509 -in /usr/local/share/ca-certificates/custom-ca.crt -outform DER) <(keytool -exportcert -keystore "'"${CACERTS}"'" -storepass changeit -alias custom-ca)'
check "environment exports available" bash -lc 'test "$NODE_EXTRA_CA_CERTS" = "/usr/local/share/ca-certificates/custom-ca.crt" && test "$SSL_CERT_FILE" = "/etc/ssl/certs/ca-certificates.crt"'
check "repeated import succeeds" /usr/local/bin/import-java-certificates
check "importer regression cases" sudo -n env JAVA_HOME="${JAVA_HOME}" bash "$(dirname "${BASH_SOURCE[0]}")/java_import_regressions.sh"

reportResults
