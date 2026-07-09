#!/usr/bin/env bash

set -e

VERSION="${VERSION:-"latest"}"
USERNAME="${USERNAME:-"${_REMOTE_USER:-"automatic"}"}"

source ./library_scripts.sh

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

ensure_uv uv_was_installed

# Determine the appropriate non-root user
if [ "${USERNAME}" = "auto" ] || [ "${USERNAME}" = "automatic" ]; then
    USERNAME=""
    POSSIBLE_USERS=("vscode" "node" "codespace" "$(awk -v val=1000 -F ":" '$3==val{print $1}' /etc/passwd)")
    for CURRENT_USER in "${POSSIBLE_USERS[@]}"; do
        if id -u "${CURRENT_USER}" > /dev/null 2>&1; then
            USERNAME="${CURRENT_USER}"
            break
        fi
    done
    if [ "${USERNAME}" = "" ]; then
        USERNAME=root
    fi
elif [ "${USERNAME}" = "none" ] || ! id -u ${USERNAME} > /dev/null 2>&1; then
    USERNAME=root
fi

# Install specify-cli
if [ "${USERNAME}" != "root" ] && [ "${USERNAME}" != "" ]; then
    # Install for the specific user
    sudo -u "${USERNAME}" bash -c "
        export PATH=\"/home/${USERNAME}/.local/bin:\$PATH\"
        if [ \"${VERSION}\" = \"latest\" ]; then
            uv tool install specify-cli --from \"git+https://github.com/github/spec-kit.git\"
        else
            uv tool install specify-cli --from \"git+https://github.com/github/spec-kit.git@${VERSION}\"
        fi
    "
    SPECIFY_PATH="/home/${USERNAME}/.local/bin"
else
    # Install for root
    if [ "${VERSION}" = "latest" ]; then
        uv tool install specify-cli --from "git+https://github.com/github/spec-kit.git"
    else
        uv tool install specify-cli --from "git+https://github.com/github/spec-kit.git@${VERSION}"
    fi
    SPECIFY_PATH="$HOME/.local/bin"
fi

# Make specify available system-wide
ln -sf "${SPECIFY_PATH}/specify" /usr/local/bin/specify

if [ "${UNINSTALL_UV}" = "true" ]; then
    cleanup_uv "$uv_was_installed"
fi

echo 'Done!'
