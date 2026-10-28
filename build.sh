#!/bin/sh
#
# os-beszel-agent build script
# Builds the FreeBSD/OPNsense .pkg package
#

set -e

PLUGIN_NAME="os-beszel-agent"
VERSION="1.0"
DIST_DIR="$(pwd)/dist"
STAGE_DIR="$(pwd)/work/stage"
META_DIR="$(pwd)/work/meta"

echo "==> Preparing build directories..."
rm -rf work dist
mkdir -p "${DIST_DIR}" "${STAGE_DIR}/usr/local" "${META_DIR}"

# If /usr/plugins/Mk/plugins.mk is present, prefer official OPNsense make package
if [ -f "/usr/plugins/Mk/plugins.mk" ]; then
    echo "==> OPNsense plugins build environment detected at /usr/plugins."
    mkdir -p /usr/plugins/sysutils/beszel-agent
    cp -r * /usr/plugins/sysutils/beszel-agent/
    cd /usr/plugins/sysutils/beszel-agent
    make package
    find work -type f \( -name "*.pkg" -o -name "*.txz" \) -exec cp {} "${DIST_DIR}/" \;
    echo "==> Package built successfully at ${DIST_DIR}/"
    exit 0
fi

# Fallback: Build package directly using FreeBSD pkg create
echo "==> Staging plugin files for pkg create..."

# 1. Copy MVC files
mkdir -p "${STAGE_DIR}/usr/local/opnsense/mvc"
cp -r src/opnsense/mvc/* "${STAGE_DIR}/usr/local/opnsense/mvc/"

# 2. Copy service files
mkdir -p "${STAGE_DIR}/usr/local/opnsense/service"
cp -r src/opnsense/service/* "${STAGE_DIR}/usr/local/opnsense/service/"

# 3. Copy scripts
mkdir -p "${STAGE_DIR}/usr/local/opnsense/scripts"
cp -r src/opnsense/scripts/* "${STAGE_DIR}/usr/local/opnsense/scripts/"

# 4. Copy rc.d script
mkdir -p "${STAGE_DIR}/usr/local/etc/rc.d"
cp src/opnsense/scripts/OPNsense/BeszelAgent/beszel_agent.rc "${STAGE_DIR}/usr/local/etc/rc.d/beszel_agent"
chmod 755 "${STAGE_DIR}/usr/local/etc/rc.d/beszel_agent"
chmod 755 "${STAGE_DIR}/usr/local/opnsense/scripts/OPNsense/BeszelAgent/"*.sh

# 5. Generate +MANIFEST
cat <<EOF > "${META_DIR}/+MANIFEST"
{
  "name": "${PLUGIN_NAME}",
  "version": "${VERSION}",
  "origin": "sysutils/${PLUGIN_NAME}",
  "comment": "Beszel Agent - lightweight server monitoring agent",
  "desc": "Beszel Agent plugin for OPNsense.\nProvides a web-based interface to configure and manage the Beszel Agent.",
  "maintainer": "handill@live.fr",
  "www": "https://github.com/henrygd/beszel",
  "prefix": "/usr/local",
  "categories": ["sysutils"]
}
EOF

# 6. Generate plist
cd "${STAGE_DIR}/usr/local"
find . -type f | sed 's|^\./||' > "${META_DIR}/plist"
cd - >/dev/null

echo "==> Packaging with pkg create..."
pkg create -M "${META_DIR}/+MANIFEST" -p "${META_DIR}/plist" -r "${STAGE_DIR}" -o "${DIST_DIR}"

echo "==> Package created in ${DIST_DIR}:"
ls -la "${DIST_DIR}"
