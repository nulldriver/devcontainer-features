#!/usr/bin/env bash

set -eu

: ${GEM:=}
gems=${GEM//,/ }

if [ -z "${gems}" ]; then
    echo "No RubyGems specified. Skip installation..."
    exit 0
fi

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

export DEBIAN_FRONTEND=noninteractive

args=("$gems")
[ -n "${VERSION:-}" ] && args+=(--version "${VERSION}")
[ -n "${PRERELEASE:-}" ] && args+=(--prerelease)

echo "Installing gems..."
gem install "${args[@]}"

echo "Done!"
