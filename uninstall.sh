#!/usr/bin/env bash
set -euo pipefail

SERVICE_USER="slyber_test"

if [ "$(id -u)" -ne 0 ]; then
    echo "[ERR] This script must be run as root (use sudo)." >&2
    exit 1
fi

echo "[INFO] Stopping and removing slyber_test service..."
systemctl stop slyber_test 2>/dev/null || true
systemctl disable slyber_test 2>/dev/null || true
rm -f /etc/systemd/system/slyber_test.service
systemctl daemon-reload

rm -f /usr/local/bin/slyber_test

if [ "${PURGE_DATA:-false}" = "true" ]; then
    if id -u "${SERVICE_USER}" >/dev/null 2>&1; then
        userdel "${SERVICE_USER}" 2>/dev/null || true
    fi
    echo "[OK] Binary, systemd service, and system user ${SERVICE_USER} removed."
else
    echo "[OK] Binary and systemd service removed (set PURGE_DATA=true to also delete system user ${SERVICE_USER})."
fi