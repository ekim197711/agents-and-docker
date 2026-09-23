#!/bin/sh
set -eu

if [ "${CLAUDE_CODE_YOLO:-false}" = "true" ]; then
    set -- --dangerously-skip-permissions "$@"
fi

exec claude "$@"
