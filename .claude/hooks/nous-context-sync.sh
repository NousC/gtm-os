#!/usr/bin/env bash
# nous-context-sync.sh: PostToolUse hook (matcher: Edit|Write).
#
# HARD auto-sync. The moment a context/*.md file is edited, push it into Nous
# (file -> graph) via scripts/nous-sync-context.mjs — so the ICP/positioning/pricing
# your agent reads and scores on is ALWAYS the current file, without anyone having to
# say "sync my ICP". This is the reliable half; the nudge hook is the soft backstop.
#
# Reads the Nous API key from NOUS_API_KEY or ~/.nous/config.json. If Nous isn't
# connected, the sync script no-ops silently. Always exits 0 — a context edit must
# never be blocked by the sync.

set -euo pipefail

INPUT="$(cat 2>/dev/null || true)"
FILE="$(printf '%s' "$INPUT" | python3 -c 'import json,sys
try:
    d=json.load(sys.stdin); print((d.get("tool_input",{}) or {}).get("file_path",""))
except Exception:
    print("")' 2>/dev/null || true)"

# Only context markdown files.
case "$FILE" in
  */context/*.md|context/*.md) ;;
  *) exit 0 ;;
esac

# Fire-and-forget the sync (its own output goes to stderr; stdout stays clean).
node "${CLAUDE_PROJECT_DIR:-.}/scripts/nous-sync-context.mjs" "$FILE" 2>&1 1>/dev/null || true
exit 0
