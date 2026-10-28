#!/bin/sh
#
# Beszel Agent setup script
# Downloads the beszel-agent binary for FreeBSD from GitHub releases
#

INSTALL_DIR="/usr/local/bin"
BINARY_NAME="beszel-agent"
BINARY_PATH="${INSTALL_DIR}/${BINARY_NAME}"

# Detect architecture
ARCH=$(uname -m)
case "${ARCH}" in
    amd64|x86_64)
        ARCH="amd64"
        ;;
    aarch64|arm64)
        ARCH="arm64"
        ;;
    *)
        echo "Unsupported architecture: ${ARCH}"
        exit 1
        ;;
esac

OS="freebsd"

echo "==> Downloading beszel-agent for ${OS}_${ARCH}..."

# Download the latest release binary
DOWNLOAD_URL="https://github.com/henrygd/beszel/releases/latest/download/beszel-agent_${OS}_${ARCH}"

# Use fetch (available on FreeBSD) or curl as fallback
if command -v fetch >/dev/null 2>&1; then
    fetch -o "${BINARY_PATH}" "${DOWNLOAD_URL}"
elif command -v curl >/dev/null 2>&1; then
    curl -sL "${DOWNLOAD_URL}" -o "${BINARY_PATH}"
else
    echo "Error: neither fetch nor curl found. Cannot download beszel-agent."
    exit 1
fi

if [ $? -ne 0 ]; then
    echo "Error: Failed to download beszel-agent."
    exit 1
fi

# Make it executable
chmod +x "${BINARY_PATH}"

echo "==> beszel-agent installed successfully at ${BINARY_PATH}"

# Verify binary
if [ -x "${BINARY_PATH}" ]; then
    echo "==> Binary verification OK"
else
    echo "Error: Binary is not executable."
    exit 1
fi
