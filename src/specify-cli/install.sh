#!/usr/bin/env bash

: ${VERSION:="latest"}

USERNAME=${USERNAME:-${_REMOTE_USER:-"automatic"}}

set -e

export TMPDIR=$(mktemp -d /tmp/feature.XXXXXX)
trap "rm -rf $TMPDIR" EXIT

# Clean up
rm -rf /var/lib/apt/lists/*

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

architecture="$(dpkg --print-architecture)"
if [ "${architecture}" != "amd64" ] && [ "${architecture}" != "arm64" ]; then
    echo "(!) Architecture $architecture unsupported"
    exit 1
fi

# Determine the appropriate non-root user
if [ "${USERNAME}" = "auto" ] || [ "${USERNAME}" = "automatic" ]; then
    USERNAME=""
    POSSIBLE_USERS=("vscode" "node" "codespace" "$(awk -v val=1000 -F ":" '$3==val{print $1}' /etc/passwd)")
    for CURRENT_USER in "${POSSIBLE_USERS[@]}"; do
        if id -u "${CURRENT_USER}" >/dev/null 2>&1; then
            USERNAME=${CURRENT_USER}
            break
        fi
    done
    if [ "${USERNAME}" = "" ]; then
        USERNAME=root
    fi
elif [ "${USERNAME}" = "none" ] || ! id -u ${USERNAME} >/dev/null 2>&1; then
    USERNAME=root
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

check_git() {
    if [ ! -x "$(command -v git)" ]; then
        check_packages git
    fi
}

export DEBIAN_FRONTEND=noninteractive

### BEGIN install

if [ "${VERSION}" = "none" ]; then
    echo "Skipping Specify CLI installation..."
    exit 0
fi

# Install prerequisites
# echo "Installing prerequisites..."
# check_packages python3 python3-pip python3-venv ca-certificates curl
# check_git

# Install uv (the modern Python package manager)
echo "Installing uv..."
if [ "${USERNAME}" != "root" ] && [ "${USERNAME}" != "" ]; then
    # Install uv for the specific user
    sudo -u "${USERNAME}" bash -c 'curl -LsSf https://astral.sh/uv/install.sh | sh'
    UV_PATH="/home/${USERNAME}/.local/bin/uv"
else
    # Install uv for root
    curl -LsSf https://astral.sh/uv/install.sh | sh
    UV_PATH="$HOME/.local/bin/uv"
fi

# Make uv available system-wide
ln -sf "$UV_PATH" /usr/local/bin/uv

# Install specify-cli
echo "Installing Specify CLI..."
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

### END install

# Clean up
rm -rf /var/lib/apt/lists/*

echo "Specify CLI installation completed!"
echo "You can now use 'specify' command to create spec-driven development projects."
