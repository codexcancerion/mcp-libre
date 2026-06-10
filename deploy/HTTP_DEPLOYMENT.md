# LibreOffice MCP HTTP Deployment

This guide explains how to deploy the LibreOffice MCP Server using HTTP transport and systemd.

## Overview

The new HTTP bridge exposes the existing FastMCP server on a local HTTP endpoint.
The MCP transport is served at `/mcp` by default and is compatible with standard MCP clients.

## New files

- `deploy/http_mcp_bridge.py` - starts the FastMCP server as an HTTP transport
- `scripts/start-http-mcp.sh` - launcher script for the HTTP bridge
- `deploy/mcp-libre-http.env.template` - environment template for service configuration
- `deploy/mcp-libre-http.service.template` - sample systemd unit template
- `deploy/install-http-mcp-service.sh` - install and start the service
- `deploy/uninstall-http-mcp-service.sh` - remove the service

## Run Locally

1. Install dependencies:
   ```bash
   uv sync
   ```

2. Start the HTTP bridge:
   ```bash
   PROJECT_ROOT="$(pwd)" \
   MCP_HTTP_HOST=127.0.0.1 \
   MCP_HTTP_PORT=3006 \
   ./scripts/start-http-mcp.sh start
   ```

3. Verify the health endpoint:
   ```bash
   curl http://127.0.0.1:3006/health
   ```

4. Use the MCP streamable HTTP endpoint:
   - Base transport path: `http://127.0.0.1:3006/mcp`
   - Standard MCP clients should connect to the streamable HTTP path

## Systemd Service Installation

1. Copy the environment template to `/etc/mcp/mcp-libre-http.env` and edit values:
   ```bash
   sudo mkdir -p /etc/mcp
   sudo cp deploy/mcp-libre-http.env.template /etc/mcp/mcp-libre-http.env
   sudo editor /etc/mcp/mcp-libre-http.env
   ```

2. Install and enable the service:
   ```bash
   sudo bash deploy/install-http-mcp-service.sh /path/to/mcp-libre
   ```

3. Check the service status:
   ```bash
   systemctl status mcp-libre-http.service
   ```

4. Verify the endpoint:
   ```bash
   curl http://127.0.0.1:3006/health
   ```

## Uninstalling

```bash
sudo bash deploy/uninstall-http-mcp-service.sh
```

## Notes

- The HTTP bridge uses `streamable-http` transport, which is the standard MCP HTTP transport mode for FastMCP.
- The service launcher sets `PYTHONPATH` to `src/` so the existing `libremcp` package is used directly.
- The service is configured to restart automatically and can be managed with `systemctl`.
