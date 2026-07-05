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

# Idempotent add: skip servers that already exist so re-runs don't fail.
# `claude mcp add` exits non-zero when a server is already configured, which
# would abort this script (set -e). First arg is the server name; the rest are
# passed verbatim to `claude mcp add`.
ensure_mcp() {
	local name="$1"
	shift
	if claude mcp get "$name" &>/dev/null; then
		echo "  ✓ ${name} already configured, skipping"
	else
		echo "  + adding ${name}"
		claude mcp add "$@"
	fi
}

ensure_mcp filesystem --scope user filesystem -- npx -y @modelcontextprotocol/server-filesystem "${HOME}/"
ensure_mcp private-journal --scope user private-journal -- npx github:obra/private-journal-mcp
ensure_mcp sequential-thinking --scope user sequential-thinking -- npx -y @modelcontextprotocol/server-sequential-thinking
ensure_mcp excalidraw --transport http --scope user excalidraw https://mcp.excalidraw.com/mcp
ensure_mcp time --scope user time -- uvx mcp-server-time
ensure_mcp git --scope user git -- uvx mcp-server-git

echo "Claude MCP setup complete."
echo "Databricks and Redshift MCP servers are provided by the dotfile-plugins marketplace plugins."
