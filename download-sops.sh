#!/bin/bash
# Download sops for your architecture
# https://github.com/getsops/sops
#
# curl -sfL https://raw.githubusercontent.com/martonsz/download-scripts/main/download-sops.sh | bash -s -- -b /usr/local/bin
#
set -e

SOPS_BIN_FOLDER="/usr/local/bin"
SOPS_VERSION="${SOPS_VERSION:-}"

usage() {
    echo "Usage: $0 [-b <bin_folder>] [-v <version>]"
    echo "  -b <bin_folder>  Specify a custom folder to store the sops binary (default: $SOPS_BIN_FOLDER)"
    echo "  -v <version>     Specify the version of sops to download (default: $SOPS_VERSION)"
    exit 1
}

get_latest_sops_version() {
    curl -s https://api.github.com/repos/getsops/sops/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/' | cut -c 2-
}

is_in_path() {
    case ":$PATH:" in
        *":$1:"*) return 0 ;;
        *) return 1 ;;
    esac
}

while getopts "b:v:h" opt; do
    case ${opt} in
        b) SOPS_BIN_FOLDER=${OPTARG};;
        v) SOPS_VERSION=${OPTARG};;
        h) usage;;
        *) usage;;
    esac
done

if touch "$SOPS_BIN_FOLDER/sops" 2>/dev/null; then
    rm "$SOPS_BIN_FOLDER/sops"
else
    echo "Cannot write to $SOPS_BIN_FOLDER. Please specify a different folder with -b or run as root"
    exit 1
fi
if [ -z "$SOPS_VERSION" ]; then
    echo "Sops version not specified. Fetching latest version"
    SOPS_VERSION=$(get_latest_sops_version)
fi

# Determine system architecture
ARCH=$(uname -m)
case $ARCH in
    x86_64)  ARCH="amd64";;
    aarch64) ARCH="arm64";;
    arm64)   ARCH="arm64";;
    *)  echo "Unsupported architecture: $ARCH"
        exit 1;;
esac

# Determine system OS
OS=$(uname -s)
case $OS in
    Linux)  OS="linux";;
    Darwin) OS="darwin";;
    *)  echo "Unsupported OS: $OS"
        exit 1;;
esac

URL="https://github.com/getsops/sops/releases/download/v${SOPS_VERSION}/sops-v${SOPS_VERSION}.${OS}.${ARCH}"

echo "Downloading sops from $URL"
curl --silent --show-error --fail-with-body -L "$URL" > "$SOPS_BIN_FOLDER/sops"
chmod +x "$SOPS_BIN_FOLDER/sops"

echo "Sops version $SOPS_VERSION has been installed to $SOPS_BIN_FOLDER"

if ! is_in_path "$SOPS_BIN_FOLDER"; then
    echo ""
    echo "WARNING: The specified binary folder $SOPS_BIN_FOLDER is not in the PATH!"
    echo ""
fi
