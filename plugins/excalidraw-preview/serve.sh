#!/usr/bin/env bash
# Starts a local Excalidraw preview server.
# Usage: ./serve.sh [port]
# The HTML page polls data.json for diagram updates written by the Claude PostToolUse hook.

set -euo pipefail

PORT="${1:-8080}"
PREVIEW_DIR="/tmp/excalidraw-preview"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

mkdir -p "${PREVIEW_DIR}"
cp "${SCRIPT_DIR}/index.html" "${PREVIEW_DIR}/index.html"

echo "Excalidraw preview server starting at http://localhost:${PORT}"
echo "Diagram updates will appear automatically when Claude creates views."
echo "Press Ctrl+C to stop."

cd "${PREVIEW_DIR}"
python3 -m http.server "${PORT}" --bind 127.0.0.1
