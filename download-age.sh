#!/bin/bash
# Download age for your architecture
# https://github.com/FiloSottile/age
# 
# curl -sfL https://raw.githubusercontent.com/martonsz/download-scripts/main/download-age.sh | bash -s -- -b /usr/local/bin

set -e

AGE_BIN_FOLDER="/usr/local/bin"
AGE_VERSION="${AGE_VERSION:-latest}"

usage() {
    echo "Usage: $0 [-b <bin_folder>] [-v <version>]"
    echo "  -b <bin_folder>  Specify a custom folder to store the age binary (default: $AGE_BIN_FOLDER)"
    echo "  -v <version>     Specify the version of age to download (default: $AGE_VERSION)"
    exit 1
}

is_in_path() {
    case ":$PATH:" in
        *":$1:"*) return 0 ;;
        *) return 1 ;;
    esac
}

while getopts "b:v:h" opt; do
    case ${opt} in
        b) AGE_BIN_FOLDER=${OPTARG};;
        v) AGE_VERSION=v${OPTARG};;
        h) usage;;
        *) usage;;
    esac
done

if ! touch "$AGE_BIN_FOLDER/age" 2>/dev/null; then
    echo "Cannot write to $AGE_BIN_FOLDER. Please specify a different folder with -b or run as root"
    exit 1
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

URL="https://dl.filippo.io/age/${AGE_VERSION}?for=${OS}/${ARCH}"

echo "Downloading age from $URL"
curl --silent --show-error --fail-with-body -L "$URL" --output - | tar -xz  -C "$AGE_BIN_FOLDER" --strip-components=1 age/age age/age-keygen

echo "age version $AGE_VERSION has been installed to $AGE_BIN_FOLDER"

if ! is_in_path "$AGE_BIN_FOLDER"; then
    echo ""
    echo "WARNING: The specified binary folder $AGE_BIN_FOLDER is not in the PATH!"
    echo ""
fi
