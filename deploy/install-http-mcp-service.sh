#!/usr/bin/env bash
# Install the LibreOffice MCP HTTP service using systemd.

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="${1:-$(cd "$SCRIPT_DIR/.." && pwd)}"
SERVICE_USER="${2:-${SUDO_USER:-$USER}}"
SERVICE_DIR="/etc/mcp"
ENV_FILE="$SERVICE_DIR/mcp-libre-http.env"
SERVICE_FILE="/etc/systemd/system/mcp-libre-http.service"
PYTHON_EXECUTABLE="${PYTHON_EXECUTABLE:-$(command -v python)}"
MCP_HTTP_HOST="${MCP_HTTP_HOST:-127.0.0.1}"
MCP_HTTP_PORT="${MCP_HTTP_PORT:-3006}"
MCP_HTTP_PATH="${MCP_HTTP_PATH:-/mcp}"
LOG_LEVEL="${LOG_LEVEL:-INFO}"

if [ "$(id -u)" -ne 0 ]; then
  echo "This installer must be run as root. Use sudo."
  exit 1
fi

mkdir -p "$SERVICE_DIR"
cat > "$ENV_FILE" <<EOF
PROJECT_ROOT=$PROJECT_ROOT
PYTHON_EXECUTABLE=$PYTHON_EXECUTABLE
MCP_HTTP_HOST=$MCP_HTTP_HOST
MCP_HTTP_PORT=$MCP_HTTP_PORT
MCP_HTTP_PATH=$MCP_HTTP_PATH
LOG_LEVEL=$LOG_LEVEL
SERVICE_USER=$SERVICE_USER
EOF

cat > "$SERVICE_FILE" <<EOF
[Unit]
Description=LibreOffice MCP HTTP Server
After=network.target

[Service]
Type=simple
EnvironmentFile=$ENV_FILE
WorkingDirectory=$PROJECT_ROOT
ExecStart=/usr/bin/env bash -c 'cd "$PROJECT_ROOT" && ./scripts/start-http-mcp.sh start'
Restart=always
RestartSec=5
User=$SERVICE_USER
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now mcp-libre-http.service

echo "Installed and started mcp-libre-http.service"
