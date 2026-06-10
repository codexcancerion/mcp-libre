#!/usr/bin/env python3
"""HTTP bridge for the LibreOffice MCP Server.

This script starts the existing FastMCP implementation in Streamable HTTP mode
and exposes the MCP transport on a local HTTP endpoint. It also adds a small
health and server info API for service deployment.
"""

import argparse
import asyncio
import logging
import os
import sys
from pathlib import Path

from starlette.responses import JSONResponse

# Add the repository src directory to the Python path
ROOT = Path(__file__).resolve().parent.parent
SRC_DIR = ROOT / "src"
if str(SRC_DIR) not in sys.path:
    sys.path.insert(0, str(SRC_DIR))

import libremcp

LOG = logging.getLogger("mcp_http_bridge")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Start the LibreOffice MCP server over HTTP transport."
    )
    parser.add_argument(
        "--host",
        default=os.environ.get("MCP_HTTP_HOST", "127.0.0.1"),
        help="HTTP host to bind to",
    )
    parser.add_argument(
        "--port",
        default=os.environ.get("MCP_HTTP_PORT", "3006"),
        type=int,
        help="HTTP port to listen on",
    )
    parser.add_argument(
        "--mount-path",
        default=os.environ.get("MCP_HTTP_PATH", "/mcp"),
        help="MCP streamable HTTP mount path",
    )
    parser.add_argument(
        "--log-level",
        default=os.environ.get("LOG_LEVEL", "INFO"),
        help="Logging level",
    )
    return parser.parse_args()


def configure_mcp_server(host: str, port: int, mount_path: str) -> None:
    """Configure the imported FastMCP instance for HTTP transport."""
    mcp = libremcp.mcp
    mcp.settings.host = host
    mcp.settings.port = port
    mcp.settings.streamable_http_path = mount_path
    LOG.info("Configured MCP HTTP transport: host=%s port=%s path=%s", host, port, mount_path)

    @mcp.custom_route("/", methods=["GET"])
    async def root_endpoint(request):
        return JSONResponse(
            {
                "name": "LibreOffice MCP HTTP Bridge",
                "version": "1.0.0",
                "transport": "streamable-http",
                "mount_path": mount_path,
                "host": host,
                "port": port,
                "health": "/health",
                "mcp": "/mcp",
            }
        )


if __name__ == "__main__":
    args = parse_args()
    logging.basicConfig(level=getattr(logging, args.log_level.upper(), logging.INFO))
    LOG.info("Starting LibreOffice MCP HTTP bridge")

    configure_mcp_server(args.host, args.port, args.mount_path)

    @libremcp.mcp.custom_route("/health", methods=["GET"])
    async def health(request):
        return JSONResponse(
            {
                "status": "healthy",
                "transport": "streamable-http",
                "mount_path": args.mount_path,
                "host": args.host,
                "port": args.port,
            }
        )

    async def run_server() -> None:
        LOG.info("Running FastMCP streamable HTTP server")
        await libremcp.mcp.run_streamable_http_async()

    try:
        asyncio.run(run_server())
    except KeyboardInterrupt:
        LOG.info("LibreOffice MCP HTTP bridge shutting down")
