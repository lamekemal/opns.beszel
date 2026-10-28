#!/bin/sh
#
# Beszel Agent setup script
# Downloads and extracts the beszel-agent binary for FreeBSD from GitHub releases
#

set -e

INSTALL_DIR="/usr/local/bin"
BINARY_NAME="beszel-agent"
BINARY_PATH="${INSTALL_DIR}/${BINARY_NAME}"
TMP_DIR=$(mktemp -d /tmp/beszel-setup.XXXXXX)

cleanup() {
    rm -rf "${TMP_DIR}"
}
trap cleanup EXIT INT TERM

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
        echo "Error: Unsupported architecture: ${ARCH}"
        exit 1
        ;;
esac

echo "==> Architecture detected: FreeBSD ${ARCH}"

TAR_FILE="${TMP_DIR}/beszel-agent.tar.gz"

download_file() {
    _url="$1"
    _out="$2"
    if command -v fetch >/dev/null 2>&1; then
        fetch -q -o "${_out}" "${_url}" 2>/dev/null
    elif command -v curl >/dev/null 2>&1; then
        curl -sSL -f -o "${_out}" "${_url}" 2>/dev/null
    else
        return 1
    fi
}

echo "==> Downloading latest beszel-agent release..."

# Try lowercase freebsd then uppercase FreeBSD naming convention
SUCCESS=0
for OS_VARIANT in "freebsd" "FreeBSD"; do
    URL="https://github.com/henrygd/beszel/releases/latest/download/beszel-agent_${OS_VARIANT}_${ARCH}.tar.gz"
    if download_file "${URL}" "${TAR_FILE}"; then
        if gzip -t "${TAR_FILE}" >/dev/null 2>&1; then
            SUCCESS=1
            break
        fi
    fi
done

if [ ${SUCCESS} -ne 1 ]; then
    echo "Error: Failed to download beszel-agent archive from GitHub releases."
    exit 1
fi

echo "==> Extracting beszel-agent binary..."
mkdir -p "${INSTALL_DIR}"
tar -xzf "${TAR_FILE}" -C "${TMP_DIR}"

if [ -f "${TMP_DIR}/${BINARY_NAME}" ]; then
    mv -f "${TMP_DIR}/${BINARY_NAME}" "${BINARY_PATH}"
else
    FOUND=$(find "${TMP_DIR}" -type f -name "${BINARY_NAME}*" | head -n 1)
    if [ -n "${FOUND}" ]; then
        mv -f "${FOUND}" "${BINARY_PATH}"
    else
        echo "Error: beszel-agent binary not found inside archive."
        exit 1
    fi
fi

chmod 755 "${BINARY_PATH}"

echo "==> beszel-agent installed successfully at ${BINARY_PATH}"
if [ -x "${BINARY_PATH}" ]; then
    echo "==> Binary verification OK"
else
    echo "Error: Binary is not executable."
    exit 1
fi
