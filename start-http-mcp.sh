#!/usr/bin/env bash
# Start the LibreOffice MCP HTTP bridge server.

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="${PROJECT_ROOT:-$(cd "$SCRIPT_DIR/.." && pwd)}"
PYTHON_EXECUTABLE="${PYTHON_EXECUTABLE:-python}"
MCP_HTTP_HOST="${MCP_HTTP_HOST:-127.0.0.1}"
MCP_HTTP_PORT="${MCP_HTTP_PORT:-3006}"
MCP_HTTP_PATH="${MCP_HTTP_PATH:-/mcp}"
LOG_LEVEL="${LOG_LEVEL:-INFO}"

cd "$PROJECT_ROOT"
export PYTHONPATH="$PROJECT_ROOT/src:$PYTHONPATH"

if [ "$1" = "health" ]; then
  curl -sf "http://$MCP_HTTP_HOST:$MCP_HTTP_PORT/health"
  exit $?
fi

if [ "$1" = "status" ]; then
  if curl -sf "http://$MCP_HTTP_HOST:$MCP_HTTP_PORT/health" >/dev/null 2>&1; then
    echo "LibreOffice MCP HTTP bridge is running on $MCP_HTTP_HOST:$MCP_HTTP_PORT"
    exit 0
  else
    echo "LibreOffice MCP HTTP bridge is not responding"
    exit 1
  fi
fi

if [ "$1" = "stop" ]; then
  echo "Stop is supported through systemd or process management."
  exit 0
fi

echo "Starting LibreOffice MCP HTTP bridge on $MCP_HTTP_HOST:$MCP_HTTP_PORT"
exec "$PYTHON_EXECUTABLE" deploy/http_mcp_bridge.py \
  --host "$MCP_HTTP_HOST" \
  --port "$MCP_HTTP_PORT" \
  --mount-path "$MCP_HTTP_PATH" \
  --log-level "$LOG_LEVEL"
