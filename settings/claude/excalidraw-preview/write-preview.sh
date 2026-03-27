#!/usr/bin/env bash
# PostToolUse hook for mcp__excalidraw__create_view
# Reads tool input from stdin, extracts elements JSON, writes to data.json for the preview server.

set -euo pipefail

PREVIEW_DIR="/tmp/excalidraw-preview"
OUTPUT_FILE="${PREVIEW_DIR}/data.json"

input=$(cat)
elements=$(echo "${input}" | jq -r '.tool_input.elements // empty')

if [ -z "${elements}" ]; then
  exit 0
fi

mkdir -p "${PREVIEW_DIR}"
echo "${elements}" > "${OUTPUT_FILE}"
