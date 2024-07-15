#!/bin/sh
# Download age for your architecture
# https://github.com/FiloSottile/age
# 
# curl -sfL https://raw.githubusercontent.com/martonsz/download-scripts/main/download-age.sh | sh -s -- -b /usr/local/bin

set -e

BIN_FOLDER="/usr/local/bin"
VERSION="${VERSION:-latest}"

usage() {
    echo "Usage: $0 [-b <bin_folder>] [-v <version>]"
    echo "  -b <bin_folder>  Specify a custom folder to store the binary (default: $BIN_FOLDER)"
    echo "  -v <version>     Specify the version to download (optional, will try to download the latest version)"
    exit 1
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

if ! touch "$BIN_FOLDER/age" 2>/dev/null; then
    rm "$BIN_FOLDER/age"
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

URL="https://dl.filippo.io/age/${VERSION}?for=${OS}/${ARCH}"

echo "Downloading from $URL"
curl --silent --show-error --fail-with-body -L "$URL" --output - | tar -xz  -C "$BIN_FOLDER" --strip-components=1 age/age age/age-keygen

echo "age version $VERSION has been installed to $BIN_FOLDER"

if ! isInPath "$BIN_FOLDER"; then
    echo ""
    echo "WARNING: The specified binary folder $BIN_FOLDER is not in the PATH!"
    echo ""
fi
