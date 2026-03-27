#!/usr/bin/env bash
# PreToolUse hook: ensures the Excalidraw preview server is running before create_view.
# Starts it backgrounded if not already up. Opens the browser on first start.

set -euo pipefail

PORT=8080
PREVIEW_DIR="/tmp/excalidraw-preview"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

if curl -s -o /dev/null --max-time 1 "http://127.0.0.1:${PORT}"; then
  exit 0
fi

mkdir -p "${PREVIEW_DIR}"
cp "${SCRIPT_DIR}/index.html" "${PREVIEW_DIR}/index.html"

cd "${PREVIEW_DIR}"
nohup python3 -m http.server "${PORT}" --bind 127.0.0.1 > /dev/null 2>&1 &

# Give the server a moment to start, then open the browser
sleep 0.5
open "http://127.0.0.1:${PORT}"
