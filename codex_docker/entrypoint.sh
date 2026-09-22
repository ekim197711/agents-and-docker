#!/bin/sh
set -eu

if [ "${CODEX_YOLO:-false}" = "true" ]; then
    set -- --dangerously-bypass-approvals-and-sandbox "$@"
fi

exec codex "$@"
