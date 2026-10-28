#!/bin/sh
#
# os-beszel-agent — Easy Installer for OPNsense
#
# Usage:
#   fetch -o - https://raw.githubusercontent.com/lamekemal/opns.beszel/main/install.sh | sh
#   or:
#   sh install.sh [--uninstall]
#

set -e

REPO_USER="lamekemal"
REPO_NAME="opns.beszel"
PLUGIN_NAME="os-beszel-agent"
DEFAULT_VERSION="1.0"

# Colors for terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

info() {
    printf "${BLUE}==>${NC} %s\n" "$1"
}

success() {
    printf "${GREEN}==> SUCCESS:${NC} %s\n" "$1"
}

warn() {
    printf "${YELLOW}==> WARNING:${NC} %s\n" "$1"
}

error() {
    printf "${RED}==> ERROR:${NC} %s\n" "$1" >&2
}

# 1. Root check
if [ "$(id -u)" -ne 0 ]; then
    error "This installer must be run as root (or via sudo)."
    exit 1
fi

# 2. OS check
if [ "$(uname -s)" != "FreeBSD" ]; then
    error "This installer is only intended for FreeBSD / OPNsense systems."
    exit 1
fi

# Handle uninstall flag
if [ "$1" = "--uninstall" ] || [ "$1" = "-u" ]; then
    info "Uninstalling ${PLUGIN_NAME}..."

    # Stop service if running
    if [ -x "/usr/local/etc/rc.d/beszel_agent" ]; then
        /usr/local/etc/rc.d/beszel_agent stop 2>/dev/null || true
    fi
    sysrc beszel_agent_enable="NO" 2>/dev/null || true

    # Remove pkg if installed via pkg
    if pkg info "${PLUGIN_NAME}" >/dev/null 2>&1; then
        pkg delete -y "${PLUGIN_NAME}" 2>/dev/null || true
    fi

    # Remove files
    rm -rf /usr/local/opnsense/mvc/app/controllers/OPNsense/BeszelAgent
    rm -rf /usr/local/opnsense/mvc/app/models/OPNsense/BeszelAgent
    rm -rf /usr/local/opnsense/mvc/app/views/OPNsense/BeszelAgent
    rm -rf /usr/local/opnsense/scripts/OPNsense/BeszelAgent
    rm -rf /usr/local/opnsense/service/templates/OPNsense/BeszelAgent
    rm -f /usr/local/opnsense/service/conf/actions.d/actions_beszelagent.conf
    rm -f /usr/local/etc/rc.d/beszel_agent
    rm -f /usr/local/etc/beszel-agent.conf
    rm -f /usr/local/bin/beszel-agent
    rm -f /var/run/beszel-agent.pid
    rm -rf /tmp/cache/*

    # Reload configd
    service configd restart >/dev/null 2>&1 || true

    success "${PLUGIN_NAME} has been completely uninstalled."
    exit 0
fi

info "Starting installation of ${PLUGIN_NAME} for OPNsense..."

TMP_DIR=$(mktemp -d /tmp/beszel-install.XXXXXX)
cleanup() {
    rm -rf "${TMP_DIR}"
}
trap cleanup EXIT INT TERM

download() {
    _url="$1"
    _dest="$2"
    if command -v fetch >/dev/null 2>&1; then
        fetch -q -o "${_dest}" "${_url}" 2>/dev/null
    elif command -v curl >/dev/null 2>&1; then
        curl -sSL -f -o "${_dest}" "${_url}" 2>/dev/null
    else
        return 1
    fi
}

INSTALLED=0

# Step A: Try to install precompiled .pkg from GitHub Releases
PKG_URL="https://github.com/${REPO_USER}/${REPO_NAME}/releases/latest/download/${PLUGIN_NAME}-${DEFAULT_VERSION}.pkg"
PKG_FILE="${TMP_DIR}/${PLUGIN_NAME}.pkg"

info "Checking for precompiled package at ${PKG_URL}..."
if download "${PKG_URL}" "${PKG_FILE}" && [ -s "${PKG_FILE}" ]; then
    info "Precompiled package found! Installing with pkg add..."
    if pkg add -f "${PKG_FILE}"; then
        INSTALLED=1
        success "Package installed via pkg add."
    fi
fi

# Step B: Fallback to direct file deployment if no release .pkg is published yet
if [ ${INSTALLED} -eq 0 ]; then
    warn "Precompiled .pkg not yet published or unreachable. Deploying files directly from repository..."

    TAR_URL="https://github.com/${REPO_USER}/${REPO_NAME}/archive/refs/heads/main.tar.gz"
    TAR_FILE="${TMP_DIR}/repo.tar.gz"

    if [ -d "./src/opnsense" ]; then
        info "Local repository detected. Using current workspace files..."
        SRC_BASE="./src/opnsense"
    else
        info "Downloading source files from GitHub (${TAR_URL})..."
        if ! download "${TAR_URL}" "${TAR_FILE}"; then
            error "Failed to download repository files."
            exit 1
        fi
        tar -xzf "${TAR_FILE}" -C "${TMP_DIR}"
        SRC_BASE="${TMP_DIR}/${REPO_NAME}-main/src/opnsense"
    fi

    info "Installing OPNsense MVC controllers, models, and views..."
    mkdir -p /usr/local/opnsense/mvc/app/controllers/OPNsense/BeszelAgent
    mkdir -p /usr/local/opnsense/mvc/app/models/OPNsense/BeszelAgent
    mkdir -p /usr/local/opnsense/mvc/app/views/OPNsense/BeszelAgent
    cp -r "${SRC_BASE}/mvc/app/controllers/OPNsense/BeszelAgent/"* /usr/local/opnsense/mvc/app/controllers/OPNsense/BeszelAgent/
    cp -r "${SRC_BASE}/mvc/app/models/OPNsense/BeszelAgent/"* /usr/local/opnsense/mvc/app/models/OPNsense/BeszelAgent/
    cp -r "${SRC_BASE}/mvc/app/views/OPNsense/BeszelAgent/"* /usr/local/opnsense/mvc/app/views/OPNsense/BeszelAgent/

    info "Installing service templates and actions..."
    mkdir -p /usr/local/opnsense/service/conf/actions.d
    mkdir -p /usr/local/opnsense/service/templates/OPNsense/BeszelAgent
    cp "${SRC_BASE}/service/conf/actions.d/actions_beszelagent.conf" /usr/local/opnsense/service/conf/actions.d/
    cp -r "${SRC_BASE}/service/templates/OPNsense/BeszelAgent/"* /usr/local/opnsense/service/templates/OPNsense/BeszelAgent/

    info "Installing backend scripts and rc.d service..."
    mkdir -p /usr/local/opnsense/scripts/OPNsense/BeszelAgent
    cp -r "${SRC_BASE}/scripts/OPNsense/BeszelAgent/"* /usr/local/opnsense/scripts/OPNsense/BeszelAgent/
    cp "${SRC_BASE}/scripts/OPNsense/BeszelAgent/beszel_agent.rc" /usr/local/etc/rc.d/beszel_agent

    chmod 755 /usr/local/etc/rc.d/beszel_agent
    chmod 755 /usr/local/opnsense/scripts/OPNsense/BeszelAgent/*.sh
fi

# Step C: Pre-download the official Beszel agent binary if missing
if [ ! -x "/usr/local/bin/beszel-agent" ]; then
    info "Pre-installing official beszel-agent binary..."
    if [ -x "/usr/local/opnsense/scripts/OPNsense/BeszelAgent/setup.sh" ]; then
        /usr/local/opnsense/scripts/OPNsense/BeszelAgent/setup.sh || warn "Could not pre-download binary right now (will download on first service start)."
    fi
fi

# Step D: Reload OPNsense subsystems
info "Reloading OPNsense configuration templates..."
configctl template reload OPNsense/BeszelAgent 2>/dev/null || true

info "Restarting configd daemon..."
service configd restart 2>/dev/null || true

info "Clearing Volt template cache..."
rm -rf /tmp/cache/*

printf "\n"
success "os-beszel-agent installed successfully!"
printf "\n"
printf "${GREEN}Next Steps:${NC}\n"
printf "1. Log into your OPNsense Web UI.\n"
printf "2. Go to ${YELLOW}Services > Beszel Agent > General${NC}.\n"
printf "3. Enter your Beszel Hub URL, Public Key, and Token.\n"
printf "4. Check ${YELLOW}'Enable Beszel Agent'${NC} and click ${YELLOW}'Save'${NC}.\n"
printf "\n"
