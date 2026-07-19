#!/usr/bin/env bash
# context-sync-nudge.sh: PostToolUse hook (matcher: Edit|Write).
#
# Soft backstop for PLAYBOOK edits. context/*.md files are pushed to Nous automatically
# by nous-context-sync.sh, but a playbook has no auto-sync, so when one is edited we
# remind the agent that the change is inert until it calls sync_playbook. (An edited
# playbook file does not change what other agents read until it is synced.)
#
# Pure local. No API keys, no network. Always exits 0.

set -euo pipefail

INPUT="$(cat 2>/dev/null || true)"
FILE="$(printf '%s' "$INPUT" | python3 -c 'import json,sys;
try:
    d=json.load(sys.stdin); ti=d.get("tool_input",{}) or {}
    print(ti.get("file_path",""))
except Exception:
    print("")' 2>/dev/null || true)"

# Only fire for playbooks — context/*.md is handled (hard-synced) by nous-context-sync.sh.
case "$FILE" in
  *playbook*|*Playbook*|*PLAYBOOK*) ;;
  *) exit 0 ;;
esac

BASENAME="$(basename "$FILE")"

read -r -d '' MSG <<EOF || true
You edited a playbook ($BASENAME). It does NOT change what other agents read until you
sync it. If Nous is wired in, call sync_playbook this turn. Do not leave an edited
playbook unsynced.
EOF

python3 -c 'import json,sys
ctx=sys.stdin.read()
print(json.dumps({"hookSpecificOutput":{"hookEventName":"PostToolUse","additionalContext":ctx},"systemMessage":"Context file edited. Sync it into the resolved record this turn."}))' <<<"$MSG" 2>/dev/null || true
exit 0
