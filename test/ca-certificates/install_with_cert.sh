#!/usr/bin/env bash

set -e

# Import 'check' command
source dev-container-features-test-lib

check "cert file exists" test -f /usr/local/share/ca-certificates/custom-ca.crt

check "cert trusted in system bundle" grep -q "NP6HhF2PRKwP" /etc/ssl/certs/ca-certificates.crt

check "NODE_EXTRA_CA_CERTS" bash -lc 'test "$NODE_EXTRA_CA_CERTS" = "/usr/local/share/ca-certificates/custom-ca.crt"'

check "SSL_CERT_FILE" bash -lc 'test "$SSL_CERT_FILE" = "/etc/ssl/certs/ca-certificates.crt"'

check "SSL_CERT_DIR" bash -lc 'test "$SSL_CERT_DIR" = "/etc/ssl/certs"'

check "REQUESTS_CA_BUNDLE" bash -lc 'test "$REQUESTS_CA_BUNDLE" = "/etc/ssl/certs/ca-certificates.crt"'

check "CURL_CA_BUNDLE" bash -lc 'test "$CURL_CA_BUNDLE" = "/etc/ssl/certs/ca-certificates.crt"'

check "GIT_SSL_CAINFO" bash -lc 'test "$GIT_SSL_CAINFO" = "/etc/ssl/certs/ca-certificates.crt"'

check "PIP_CERT" bash -lc 'test "$PIP_CERT" = "/etc/ssl/certs/ca-certificates.crt"'

check "AWS_CA_BUNDLE" bash -lc 'test "$AWS_CA_BUNDLE" = "/etc/ssl/certs/ca-certificates.crt"'

reportResults
