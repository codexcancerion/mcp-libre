#!/usr/bin/env bash
# Uninstall the LibreOffice MCP HTTP systemd service.

set -e
SERVICE_DIR="/etc/mcp"
ENV_FILE="$SERVICE_DIR/mcp-libre-http.env"
SERVICE_FILE="/etc/systemd/system/mcp-libre-http.service"

if [ "$(id -u)" -ne 0 ]; then
  echo "This uninstaller must be run as root. Use sudo."
  exit 1
fi

if systemctl is-active --quiet mcp-libre-http.service; then
  systemctl stop mcp-libre-http.service
fi

if systemctl is-enabled --quiet mcp-libre-http.service; then
  systemctl disable mcp-libre-http.service
fi

rm -f "$SERVICE_FILE"
rm -f "$ENV_FILE"

if [ -d "$SERVICE_DIR" ] && [ -z "$(ls -A "$SERVICE_DIR")" ]; then
  rmdir "$SERVICE_DIR"
fi

systemctl daemon-reload

echo "Uninstalled mcp-libre-http.service"
