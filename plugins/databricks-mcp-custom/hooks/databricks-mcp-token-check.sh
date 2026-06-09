#!/bin/bash
# PreToolUse hook: detect stale Databricks OAuth tokens
# Checks how long ago the MCP server was started. If > 50 minutes,
# the OAuth token has likely expired and the server needs a restart.

set -euo pipefail

MAX_AGE_SECONDS=3000  # 50 minutes

# Read hook input from stdin
INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')

if [[ -z "$TOOL_NAME" ]]; then
  exit 0
fi

# Map tool name to Databricks CLI profile
case "$TOOL_NAME" in
  mcp__databricks-dbsql-dev__*)       PROFILE="DEV" ;;
  mcp__databricks-dbsql-prod__*)      PROFILE="PROD" ;;
  mcp__databricks-dbsql-sandbox__*)   PROFILE="SANDBOX" ;;
  mcp__databricks-dbsql-adhoc-analysis__*) PROFILE="ADHOC-ANALYSIS" ;;
  *) exit 0 ;;  # Not a Databricks tool, allow
esac

TIMESTAMP_FILE="$HOME/.cache/claude/databricks-mcp-start-${PROFILE}"

if [[ ! -f "$TIMESTAMP_FILE" ]]; then
  echo "Databricks MCP server for ${PROFILE} has no recorded start time."
  echo "Restart the MCP server via /mcp to refresh the OAuth token."
  exit 2
fi

START_TIME=$(cat "$TIMESTAMP_FILE")
NOW=$(date +%s)
AGE=$(( NOW - START_TIME ))

if (( AGE > MAX_AGE_SECONDS )); then
  MINUTES=$(( AGE / 60 ))
  echo "Databricks ${PROFILE} OAuth token is likely expired (MCP server started ${MINUTES}m ago)."
  echo "Restart the MCP server via /mcp to refresh the token."
  exit 2
fi

exit 0
