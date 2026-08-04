#!/usr/bin/env bash
# PostToolUse hook for mcp__excalidraw__create_view
# Reads tool input from stdin, extracts elements JSON, writes to data.json for the preview server.

set -euo pipefail

PREVIEW_DIR="/tmp/excalidraw-preview"
OUTPUT_FILE="${PREVIEW_DIR}/data.json"

input=$(cat)
# running a longer python command to avoid extra dependencies like jq
elements=$(echo "${input}" | python3 -c '
import json, sys
e = json.load(sys.stdin).get("tool_input", {}).get("elements")
if e is not None:
    print(e if isinstance(e, str) else json.dumps(e))
')

if [ -z "${elements}" ]; then
  exit 0
fi

mkdir -p "${PREVIEW_DIR}"
echo "${elements}" > "${OUTPUT_FILE}"
