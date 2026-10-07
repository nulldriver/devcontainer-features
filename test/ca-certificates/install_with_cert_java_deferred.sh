#!/bin/bash
# Verify Java trust when the CA feature installs before the upstream JDK.

set -e

# shellcheck source=install_with_cert_java.sh
source "$(dirname "${BASH_SOURCE[0]}")/install_with_cert_java.sh"
