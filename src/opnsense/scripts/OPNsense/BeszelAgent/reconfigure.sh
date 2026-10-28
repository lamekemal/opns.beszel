#!/bin/sh
#
# Beszel Agent reconfigure script
# Called by configd when the user saves settings
#

CONFIG_FILE="/usr/local/etc/beszel-agent.conf"
RC_SCRIPT="/usr/local/etc/rc.d/beszel_agent"

# Regenerate config template
/usr/local/bin/configctl template reload OPNsense/BeszelAgent 2>/dev/null

# Read enabled status from the generated config
if [ -f "${CONFIG_FILE}" ]; then
    . "${CONFIG_FILE}"

    # Check if there's actual content (service is enabled)
    HUB_URL_VAL=$(grep "^HUB_URL=" "${CONFIG_FILE}" 2>/dev/null | head -1 | cut -d'"' -f2)

    if [ -n "${HUB_URL_VAL}" ]; then
        # Service is enabled — ensure rc.conf is set and restart
        sysrc beszel_agent_enable="YES" >/dev/null 2>&1

        # Ensure the binary is present
        if [ ! -x "/usr/local/bin/beszel-agent" ]; then
            /usr/local/opnsense/scripts/OPNsense/BeszelAgent/setup.sh
        fi

        # Restart the service
        if [ -x "${RC_SCRIPT}" ]; then
            ${RC_SCRIPT} restart
        fi
    else
        # Service is disabled — stop and disable
        sysrc beszel_agent_enable="NO" >/dev/null 2>&1
        if [ -x "${RC_SCRIPT}" ]; then
            ${RC_SCRIPT} stop 2>/dev/null
        fi
    fi
else
    # No config file — disable
    sysrc beszel_agent_enable="NO" >/dev/null 2>&1
    if [ -x "${RC_SCRIPT}" ]; then
        ${RC_SCRIPT} stop 2>/dev/null
    fi
fi

echo "OK"
