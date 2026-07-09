#!/usr/bin/env bash

clean_download() {
    # The purpose of this function is to download a file with minimal impact on container layer size
    # this means if no valid downloader is found (curl or wget) then we install a downloader (currently wget) in a
    # temporary manner, and making sure to
    # 1. uninstall the downloader at the return of the function
    # 2. revert back any changes to the package installer database/cache (for example apt-get lists)
    # The above steps will minimize the leftovers being created while installing the downloader
    # Supported distros:
    #  debian/ubuntu/alpine

    url=$1
    output_location=$2
    tempdir=$(mktemp -d)
    downloader_installed=""

    function _apt_get_install() {
        tempdir=$1

        # copy current state of apt list - in order to revert back later (minimize contianer layer size)
        cp -p -R /var/lib/apt/lists $tempdir
        apt-get update -y
        apt-get -y install --no-install-recommends wget ca-certificates
    }

    function _apt_get_cleanup() {
        tempdir=$1

        echo "removing wget"
        apt-get -y purge wget --auto-remove

        echo "revert back apt lists"
        rm -rf /var/lib/apt/lists/*
        rm -r /var/lib/apt/lists && mv $tempdir/lists /var/lib/apt/lists
    }

    function _apk_install() {
        tempdir=$1
        # copy current state of apk cache - in order to revert back later (minimize contianer layer size)
        cp -p -R /var/cache/apk $tempdir

        apk add --no-cache wget
    }

    function _apk_cleanup() {
        tempdir=$1

        echo "removing wget"
        apk del wget
    }
    # try to use either wget or curl if one of them already installer
    if type curl >/dev/null 2>&1; then
        downloader=curl
    elif type wget >/dev/null 2>&1; then
        downloader=wget
    else
        downloader=""
    fi

    # in case none of them is installed, install wget temporarly
    if [ -z $downloader ]; then
        if [ -x "/usr/bin/apt-get" ]; then
            _apt_get_install $tempdir
        elif [ -x "/sbin/apk" ]; then
            _apk_install $tempdir
        else
            echo "distro not supported"
            exit 1
        fi
        downloader="wget"
        downloader_installed="true"
    fi

    if [ $downloader = "wget" ]; then
        wget -q $url -O $output_location
    else
        curl -sfL $url -o $output_location
    fi

    # NOTE: the cleanup procedure was not implemented using `trap X RETURN` only because
    # alpine lack bash, and RETURN is not a valid signal under sh shell
    if ! [ -z $downloader_installed ]; then
        if [ -x "/usr/bin/apt-get" ]; then
            _apt_get_cleanup $tempdir
        elif [ -x "/sbin/apk" ]; then
            _apk_cleanup $tempdir
        else
            echo "distro not supported"
            exit 1
        fi
    fi

}

ensure_nanolayer() {
    # Ensure existance of the nanolayer cli program
    local variable_name=$1

    local required_version=$2
    # normalize version
    if ! [[ $required_version == v* ]]; then
        required_version=v$required_version
    fi

    local nanolayer_location=""

    # If possible - try to use an already installed nanolayer
    if [[ -z "${NANOLAYER_FORCE_CLI_INSTALLATION}" ]]; then
        if [[ -z "${NANOLAYER_CLI_LOCATION}" ]]; then
            if type nanolayer >/dev/null 2>&1; then
                echo "Found a pre-existing nanolayer in PATH"
                nanolayer_location=nanolayer
            fi
        elif [ -f "${NANOLAYER_CLI_LOCATION}" ] && [ -x "${NANOLAYER_CLI_LOCATION}" ]; then
            nanolayer_location=${NANOLAYER_CLI_LOCATION}
            echo "Found a pre-existing nanolayer which were given in env variable: $nanolayer_location"
        fi

        # make sure its of the required version
        if ! [[ -z "${nanolayer_location}" ]]; then
            local current_version
            current_version=$($nanolayer_location --version)
            if ! [[ $current_version == v* ]]; then
                current_version=v$current_version
            fi

            if ! [ $current_version == $required_version ]; then
                echo "skipping usage of pre-existing nanolayer. (required version $required_version does not match existing version $current_version)"
                nanolayer_location=""
            fi
        fi

    fi

    # If not previuse installation found, download it temporarly and delete at the end of the script
    if [[ -z "${nanolayer_location}" ]]; then

        if [ "$(uname -sm)" == "Linux x86_64" ] || [ "$(uname -sm)" == "Linux aarch64" ]; then
            tmp_dir=$(mktemp -d -t nanolayer-XXXXXXXXXX)

            clean_up() {
                ARG=$?
                rm -rf $tmp_dir
                exit $ARG
            }
            trap clean_up EXIT

            if [ -x "/sbin/apk" ]; then
                clib_type=musl
            else
                clib_type=gnu
            fi

            tar_filename=nanolayer-"$(uname -m)"-unknown-linux-$clib_type.tgz

            # clean download will minimize leftover in case a downloaderlike wget or curl need to be installed
            clean_download https://github.com/devcontainers-extra/nanolayer/releases/download/$required_version/$tar_filename $tmp_dir/$tar_filename

            tar xfzv $tmp_dir/$tar_filename -C "$tmp_dir"
            chmod a+x $tmp_dir/nanolayer
            nanolayer_location=$tmp_dir/nanolayer

        else
            echo "No binaries compiled for non-x86-linux architectures yet: $(uname -m)"
            exit 1
        fi
    fi

    # Expose outside the resolved location
    declare -g ${variable_name}=$nanolayer_location

}

ensure_uv() {
    # Ensure uv is available, installing it temporarily if needed
    # Returns: sets uv_was_installed=true if we installed it (caller should clean up)

    local variable_name=$1
    local uv_was_installed=
    
    if type uv >/dev/null 2>&1; then
        echo "uv is already installed, skipping installation"
        uv_was_installed=false
    else
        echo "uv is not installed, installing via nanolayer"
        
        ensure_nanolayer nanolayer_location "v0.5.6"
        
        $nanolayer_location \
            install \
            devcontainer-feature \
            "ghcr.io/devcontainers-extra/features/uv:1"
        
        uv_was_installed=true
    fi

    # Expose outside the resolved location
    declare -g ${variable_name}=$uv_was_installed
}

cleanup_uv() {
    # Remove uv if it was installed by ensure_uv
    # Should only be called if uv_was_installed=true

    local uv_was_installed=$1

    if [ "$uv_was_installed" != true ]; then
        echo "uv was not installed by ensure_uv, skipping cleanup"
        return
    fi

    echo "Cleaning up uv installation"

    # Clean up stored data
    uv cache clean 2>/dev/null || true

    local python_dir=$(uv python dir 2>/dev/null || echo "")
    if [ -n "$python_dir" ] && [ -d "$python_dir" ]; then
        rm -rf "$python_dir"
    fi

    local tool_dir=$(uv tool dir 2>/dev/null || echo "")
    if [ -n "$tool_dir" ] && [ -d "$tool_dir" ]; then
        rm -rf "$tool_dir"
    fi

    # Remove the uv and uvx binaries
    rm -f ~/.local/bin/uv ~/.local/bin/uvx
    
    # Remove from other locations
    rm -f /usr/local/bin/uv /usr/local/bin/uvx
}
