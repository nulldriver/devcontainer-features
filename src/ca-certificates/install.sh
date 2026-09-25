#!/usr/bin/env bash

: ${CERT:=""}
: ${CERT_FILENAME:="custom-ca.crt"}
: ${SET_ENV_VARS:="true"}
: ${JAVA_TRUSTSTORE_PASSWORD:="changeit"}

set -e

export TMPDIR=$(mktemp -d /tmp/feature.XXXXXX)
trap "rm -rf $TMPDIR" EXIT

# Clean up
rm -rf /var/lib/apt/lists/*

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

apt_get_update() {
    if [ "$(find /var/lib/apt/lists/* | wc -l)" = "0" ]; then
        echo "Running apt-get update..."
        apt-get update -y
    fi
}

# Checks if packages are installed and installs them if not
check_packages() {
    if ! dpkg -s "$@" >/dev/null 2>&1; then
        apt_get_update
        apt-get -y install --no-install-recommends "$@"
    fi
}

export DEBIAN_FRONTEND=noninteractive

### BEGIN install

if [ -z "${CERT}" ]; then
    echo "No CA certificate provided. Skipping installation..."
    exit 0
fi

check_packages ca-certificates

# Sanitize the filename: basename only (no path traversal), force a .crt suffix
CERT_FILENAME="$(basename -- "${CERT_FILENAME}")"
CERT_FILENAME="${CERT_FILENAME//../}"
if [ -z "${CERT_FILENAME}" ] || [ "${CERT_FILENAME}" = ".crt" ]; then
    CERT_FILENAME="custom-ca.crt"
fi
case "${CERT_FILENAME}" in
    *.crt) ;;
    *) CERT_FILENAME="${CERT_FILENAME}.crt" ;;
esac

# Basic sanity check that this looks like a PEM certificate before writing it into the trust store
if ! printf '%s' "${CERT}" | grep -q -- "-----BEGIN CERTIFICATE-----"; then
    echo "(!) The provided 'cert' option does not look like a PEM-encoded certificate (missing '-----BEGIN CERTIFICATE-----')."
    exit 1
fi

CERT_PATH="/usr/local/share/ca-certificates/${CERT_FILENAME}"
BUNDLE_PATH="/etc/ssl/certs/ca-certificates.crt"

# Imports the certificate into the truststore ("cacerts") of whichever JDK's
# "keytool" is found on PATH. This is a best-effort operation: if no JDK is
# installed (or the JDK feature installs after this one), it is silently
# skipped since Java support is optional and not guaranteed to be present.
import_into_java_truststore() {
    if ! command -v keytool >/dev/null 2>&1; then
        echo "keytool not found on PATH. Skipping Java truststore import..."
        return 0
    fi

    local keytool_path java_home cacerts_path java_alias
    keytool_path="$(readlink -f "$(command -v keytool)")"
    java_home="${JAVA_HOME:-$(dirname "$(dirname "${keytool_path}")")}"

    if [ -f "${java_home}/lib/security/cacerts" ]; then
        cacerts_path="${java_home}/lib/security/cacerts"
    elif [ -f "${java_home}/jre/lib/security/cacerts" ]; then
        cacerts_path="${java_home}/jre/lib/security/cacerts"
    else
        echo "(!) Found keytool but could not locate a 'cacerts' truststore under ${java_home}. Skipping Java truststore import..."
        return 0
    fi

    # Derive a keytool-safe alias from the certificate filename (strip the
    # .crt suffix, replace anything but alphanumerics/dot/dash/underscore).
    java_alias="${CERT_FILENAME%.crt}"
    java_alias="$(printf '%s' "${java_alias}" | tr -c 'A-Za-z0-9._-' '-')"

    echo "Importing custom CA certificate into Java truststore at ${cacerts_path}..."

    # Remove any pre-existing alias so re-running this script is idempotent.
    keytool -delete -noprompt -alias "${java_alias}" -keystore "${cacerts_path}" -storepass "${JAVA_TRUSTSTORE_PASSWORD}" >/dev/null 2>&1 || true

    keytool -importcert -noprompt -trustcacerts \
        -alias "${java_alias}" \
        -file "${CERT_PATH}" \
        -keystore "${cacerts_path}" \
        -storepass "${JAVA_TRUSTSTORE_PASSWORD}"
}

echo "Installing custom CA certificate to ${CERT_PATH}..."
printf '%s\n' "${CERT}" > "${CERT_PATH}"
chmod 644 "${CERT_PATH}"

update-ca-certificates

if [ "${SET_ENV_VARS}" = "true" ]; then
    echo "Exporting CA certificate environment variables..."

    ENV_BLOCK_START="# BEGIN ca-certificates feature"
    ENV_BLOCK_END="# END ca-certificates feature"

    # /etc/environment: plain KEY=value, no quoting/expansion, read by PAM-based login
    # sessions (ssh, login) and VS Code / Codespaces remote server startup.
    if [ -f /etc/environment ]; then
        sed -i "/^${ENV_BLOCK_START}$/,/^${ENV_BLOCK_END}$/d" /etc/environment
    fi
    {
        echo "${ENV_BLOCK_START}"
        echo "NODE_EXTRA_CA_CERTS=${CERT_PATH}"
        echo "SSL_CERT_FILE=${BUNDLE_PATH}"
        echo "SSL_CERT_DIR=/etc/ssl/certs"
        echo "REQUESTS_CA_BUNDLE=${BUNDLE_PATH}"
        echo "CURL_CA_BUNDLE=${BUNDLE_PATH}"
        echo "GIT_SSL_CAINFO=${BUNDLE_PATH}"
        echo "PIP_CERT=${BUNDLE_PATH}"
        echo "AWS_CA_BUNDLE=${BUNDLE_PATH}"
        echo "${ENV_BLOCK_END}"
    } >> /etc/environment

    # /etc/profile.d: exported for interactive login shells (bash -l, sh -l).
    cat > /etc/profile.d/00-ca-certificates.sh <<EOF
${ENV_BLOCK_START}
export NODE_EXTRA_CA_CERTS="${CERT_PATH}"
export SSL_CERT_FILE="${BUNDLE_PATH}"
export SSL_CERT_DIR="/etc/ssl/certs"
export REQUESTS_CA_BUNDLE="${BUNDLE_PATH}"
export CURL_CA_BUNDLE="${BUNDLE_PATH}"
export GIT_SSL_CAINFO="${BUNDLE_PATH}"
export PIP_CERT="${BUNDLE_PATH}"
export AWS_CA_BUNDLE="${BUNDLE_PATH}"
${ENV_BLOCK_END}
EOF
    chmod 755 /etc/profile.d/00-ca-certificates.sh

    import_into_java_truststore
fi

### END install

# Clean up
rm -rf /var/lib/apt/lists/*

echo "Done!"
