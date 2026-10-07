#!/bin/bash
# Exercise importer error paths and isolated truststores as root with JAVA_HOME.

set -euo pipefail

readonly CONFIG_DIR="/usr/local/share/ca-certificates-feature"
readonly IMPORTER="/usr/local/bin/import-java-certificates"

cleanup() {
  cp "${TEST_DIR}/java.conf" "${CONFIG_DIR}/java.conf"
  cp "${TEST_DIR}/java-password" "${CONFIG_DIR}/java-password"
  rm -rf "${TEST_DIR}"
}

#######################################
# Assert that a command fails and emits a diagnostic.
# Globals:
#   TEST_DIR
# Arguments:
#   Command and its arguments.
# Outputs:
#   Writes unexpected-success diagnostics to stderr.
# Returns:
#   0 if the command fails with diagnostics; exits 1 if it succeeds.
#######################################
expect_failure() {
  if "$@" >"${TEST_DIR}/error.log" 2>&1; then
    echo "Expected failure: $*" >&2
    cat "${TEST_DIR}/error.log" >&2
    exit 1
  fi
  test -s "${TEST_DIR}/error.log"
}

#######################################
# Run regression cases and restore the importer's configuration on exit.
# Globals:
#   CONFIG_DIR
#   IMPORTER
#   JAVA_HOME
#   TEST_DIR
#   CERT_FILENAME
#   CERT_PATH
# Arguments:
#   None.
# Outputs:
#   Writes importer and keytool diagnostics to stdout and stderr.
# Returns:
#   0 if all regression cases pass; exits nonzero on failure.
#######################################
main() {
  local keytool original_home store cert_filename
  TEST_DIR="$(mktemp -d)"
  readonly TEST_DIR
  cp "${CONFIG_DIR}/java.conf" "${TEST_DIR}/java.conf"
  cp "${CONFIG_DIR}/java-password" "${TEST_DIR}/java-password"
  trap cleanup EXIT

  keytool="$(readlink -f "${JAVA_HOME}/bin/keytool")"
  original_home="$(dirname "$(dirname "${keytool}")")"
  mkdir -p "${TEST_DIR}/jdk/bin" "${TEST_DIR}/jdk/lib/security"
  ln -s "${keytool}" "${TEST_DIR}/jdk/bin/keytool"
  export JAVA_HOME="${TEST_DIR}/jdk"
  store="${JAVA_HOME}/lib/security/cacerts"
  "${keytool}" -importcert -noprompt \
    -file /usr/local/share/ca-certificates/custom-ca.crt \
    -keystore "${store}" -storetype JKS -storepass changeit -alias custom-ca

  printf 'wrong-password' >"${CONFIG_DIR}/java-password"
  expect_failure "${IMPORTER}"
  grep -qi "password" "${TEST_DIR}/error.log"
  "${keytool}" -list -keystore "${store}" -storepass changeit \
    -alias custom-ca >/dev/null

  cp "${TEST_DIR}/java-password" "${CONFIG_DIR}/java-password"
  printf 'not a certificate' >"${TEST_DIR}/invalid.crt"
  printf 'CERT_PATH=%q\n' "${TEST_DIR}/invalid.crt" >>"${CONFIG_DIR}/java.conf"
  expect_failure "${IMPORTER}"
  "${keytool}" -list -keystore "${store}" -storepass changeit \
    -alias custom-ca >/dev/null
  cp "${TEST_DIR}/java.conf" "${CONFIG_DIR}/java.conf"

  "${keytool}" -storepasswd -keystore "${store}" -storepass changeit \
    -new 'custom password'
  printf 'custom password' >"${CONFIG_DIR}/java-password"
  # shellcheck source=/dev/null
  source "${CONFIG_DIR}/java.conf"
  cert_filename="custom filename.crt"
  {
    printf 'CERT_FILENAME=%q\n' "${cert_filename}"
    printf 'CERT_PATH=%q\n' "${CERT_PATH}"
  } >"${CONFIG_DIR}/java.conf"
  "${IMPORTER}"
  "${IMPORTER}"
  "${keytool}" -list -keystore "${store}" -storepass 'custom password' \
    -alias custom-filename >/dev/null
  # Updating one alias must not remove other trusted certificates.
  "${keytool}" -list -keystore "${store}" -storepass 'custom password' \
    -alias custom-ca >/dev/null

  expect_failure su -s /bin/bash nobody -c "'${IMPORTER}' '${original_home}'"
  grep -qi "sudo" "${TEST_DIR}/error.log"

  mkdir -p "${JAVA_HOME}/jre/lib/security"
  mv "${store}" "${JAVA_HOME}/jre/lib/security/cacerts"
  "${IMPORTER}"
  "${keytool}" -list -keystore "${JAVA_HOME}/jre/lib/security/cacerts" \
    -storepass 'custom password' -alias custom-filename >/dev/null

  mv "${JAVA_HOME}/jre/lib/security/cacerts" "${TEST_DIR}/cacerts"
  expect_failure "${IMPORTER}"
  grep -q "Cannot locate" "${TEST_DIR}/error.log"

  env -u JAVA_HOME PATH=/usr/bin:/bin "${IMPORTER}" >"${TEST_DIR}/no-java.log"
  grep -q "No JDK found" "${TEST_DIR}/no-java.log"

  rm "${CONFIG_DIR}/java.conf"
  "${IMPORTER}"
}

main "$@"
