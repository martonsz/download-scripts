#!/bin/sh
# Download sops for your architecture
# https://github.com/getsops/sops
#
# curl -sfL https://raw.githubusercontent.com/martonsz/download-scripts/main/download-sops.sh | sh -s -- -b /usr/local/bin
#
set -e

BIN_FOLDER="/usr/local/bin"
VERSION="${VERSION:-}"

usage() {
    echo "Usage: $0 [-b <bin_folder>] [-v <version>]"
    echo "  -b <bin_folder>  Specify a custom folder to store the binary (default: $BIN_FOLDER)"
    echo "  -v <version>     Specify the version to download (optional, will try to download the latest version)"
    exit 1
}

getLatestVersion() {
    curl -s https://api.github.com/repos/getsops/sops/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/' | cut -c 2-
}

isInPath() {
    case ":$PATH:" in
        *":$1:"*) return 0 ;;
        *) return 1 ;;
    esac
}

while getopts "b:v:h" opt; do
    case ${opt} in
        b) BIN_FOLDER=${OPTARG};;
        v) VERSION=${OPTARG};;
        h) usage;;
        *) usage;;
    esac
done

if touch "$BIN_FOLDER/sops" 2>/dev/null; then
    rm "$BIN_FOLDER/sops"
else
    echo "Cannot write to $BIN_FOLDER. Please specify a different folder with -b or run as root"
    exit 1
fi
if [ -z "$VERSION" ]; then
    echo "Version not specified. Fetching latest version"
    VERSION=$(getLatestVersion)
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

URL="https://github.com/getsops/sops/releases/download/v${VERSION}/sops-v${VERSION}.${OS}.${ARCH}"

echo "Downloading from $URL"
curl --silent --show-error --fail-with-body -L "$URL" > "$BIN_FOLDER/sops"
chmod +x "$BIN_FOLDER/sops"

echo "Sops version $VERSION has been installed to $BIN_FOLDER"

if ! isInPath "$BIN_FOLDER"; then
    echo ""
    echo "WARNING: The specified binary folder $BIN_FOLDER is not in the PATH!"
    echo ""
fi
