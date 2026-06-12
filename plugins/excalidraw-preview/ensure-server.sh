#!/usr/bin/env bash
# PreToolUse hook: ensures the Excalidraw preview server is running before create_view.
# Starts it backgrounded if not already up. Opens the browser whenever no tab is
# actively viewing: the preview page polls data.json every 1s, so a fresh access-log
# mtime means a live viewer. The liveness probe uses a bare TCP connect (nc -z), which
# http.server does not log, so the heartbeat reflects viewer traffic only.

set -euo pipefail

PORT=8080
PREVIEW_DIR="/tmp/excalidraw-preview"
ACCESS_LOG="${PREVIEW_DIR}/access.log"
HEARTBEAT_STALE_SECS=5
URL="http://127.0.0.1:${PORT}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Always refresh HTML so edits to index.html take effect immediately
mkdir -p "${PREVIEW_DIR}"
cp "${SCRIPT_DIR}/index.html" "${PREVIEW_DIR}/index.html"

if nc -z -w 1 127.0.0.1 "${PORT}" 2>/dev/null; then
  last_activity=$(stat -f %m "${ACCESS_LOG}" 2>/dev/null || echo 0)
  if (( $(date +%s) - last_activity > HEARTBEAT_STALE_SECS )); then
    open "${URL}"
  fi
  # Cap log growth. Safe under a live writer: >> opens with O_APPEND, and the
  # staleness decision above already captured the pre-truncation mtime.
  if [ -f "${ACCESS_LOG}" ] && [ "$(stat -f %z "${ACCESS_LOG}")" -gt 5242880 ]; then
    : > "${ACCESS_LOG}"
  fi
  exit 0
fi

cd "${PREVIEW_DIR}"
nohup python3 -m http.server "${PORT}" --bind 127.0.0.1 >> "${ACCESS_LOG}" 2>&1 &

# Give the server a moment to start, then open the browser
sleep 0.5
open "${URL}"
