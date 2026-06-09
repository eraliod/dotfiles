#!/usr/bin/env bash
#
# Configure Claude Code MCP servers that aren't provided by plugins
#
# Plugin-based MCP servers (databricks, redshift, excalidraw-preview hooks)
# are wired up through the dotfile-plugins marketplace; this script only
# registers the small set of user-scope MCP servers that have no plugin yet.
#
set -euo pipefail

if ! command -v claude &>/dev/null; then
	echo "claude CLI not found. Install via brew bundle (cask 'claude-code'), then re-run."
	exit 0
fi

echo "Adding user-scope Claude Code MCP servers..."

claude mcp add --scope user filesystem -- npx -y @modelcontextprotocol/server-filesystem "${HOME}/"
claude mcp add --scope user private-journal -- npx github:obra/private-journal-mcp
claude mcp add --scope user sequential-thinking -- npx -y @modelcontextprotocol/server-sequential-thinking
claude mcp add --transport http --scope user excalidraw https://mcp.excalidraw.com/mcp
claude mcp add --scope user time -- uvx mcp-server-time
claude mcp add --scope user git -- uvx mcp-server-git

echo "Claude MCP setup complete."
echo "Databricks and Redshift MCP servers are provided by the dotfile-plugins marketplace plugins."
