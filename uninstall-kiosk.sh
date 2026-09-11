#!/usr/bin/env bash

set -Eeuo pipefail

# ============================================================
# Ubuntu 24.04 GNOME Native Windows App Kiosk Uninstall Script
# ============================================================

SCRIPT_NAME="$(basename "$0")"

# Root privilege check & sudo fallback
if [[ "${EUID}" -ne 0 ]]; then
    if ! sudo -v; then
        echo "ERROR: sudo access is required."
        exit 1
    fi
    SUDO="sudo"
else
    SUDO=""
fi

KIOSK_USER="${1:-kiosk.user}"

echo "Starting removal of kiosk configuration for target user: ${KIOSK_USER}..."

# ------------------------------------------------------------
# 1. Remove dconf System Profiles & Lock Databases
# ------------------------------------------------------------

echo "Removing dconf lockdown profiles..."

if [[ -f /etc/dconf/profile/user ]]; then
    ${SUDO} rm -f /etc/dconf/profile/user
fi

if [[ -d /etc/dconf/db/kiosk.d ]]; then
    ${SUDO} rm -rf /etc/dconf/db/kiosk.d
fi

# Refresh dconf system databases
${SUDO} dconf update

# ------------------------------------------------------------
# 2. Remove Polkit Rules
# ------------------------------------------------------------

echo "Removing polkit power rules..."

if [[ -f /etc/polkit-1/rules.d/49-kiosk-power.rules ]]; then
    ${SUDO} rm -f /etc/polkit-1/rules.d/49-kiosk-power.rules
fi

# ------------------------------------------------------------
# 3. Clean AccountsService Entries
# ------------------------------------------------------------

echo "Cleaning AccountsService configurations..."

if [[ -f "/var/lib/AccountsService/users/${KIOSK_USER}" ]]; then
    ${SUDO} rm -f "/var/lib/AccountsService/users/${KIOSK_USER}"
fi

# ------------------------------------------------------------
# 4. Remove Local Kiosk User Configurations & User Account
# ------------------------------------------------------------

if id "${KIOSK_USER}" >/dev/null 2>&1; then
    USER_HOME="$(getent passwd "${KIOSK_USER}" | cut -d: -f6)"

    # Kill running processes belonging to kiosk user
    echo "Stopping running processes for ${KIOSK_USER}..."
    ${SUDO} pkill -U "${KIOSK_USER}" || true

    # Remove user account and home directory
    echo "Deleting kiosk user account: ${KIOSK_USER}..."
    ${SUDO} userdel --remove "${KIOSK_USER}" 2>/dev/null || ${SUDO} userdel -f "${KIOSK_USER}" 2>/dev/null || true

    if [[ -d "${USER_HOME}" ]]; then
        ${SUDO} rm -rf "${USER_HOME}"
    fi
else
    echo "User ${KIOSK_USER} not found, skipping user deletion."
fi

echo "============================================================"
echo "Uninstallation complete. Kiosk restrictions have been removed."
echo "Please restart GDM or reboot the machine to finalize changes."
echo "============================================================"
