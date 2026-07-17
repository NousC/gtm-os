#!/usr/bin/env bash
# context-sync-nudge.sh — PostToolUse hook (matcher: Edit|Write).
#
# When a context file or a playbook gets edited, remind the agent that the change does not
# reach the score or the other agents until it is synced into the resolved record. This is
# the memory-protocol rule made automatic: never leave an edited context file unsynced.
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

# Only fire when a context file or a playbook changed.
case "$FILE" in
  */context/*.md|*context/*.md) IS_CONTEXT=1 ;;
  *playbook*|*Playbook*|*PLAYBOOK*) IS_CONTEXT=1 ;;
  *) IS_CONTEXT=0 ;;
esac
[ "$IS_CONTEXT" = "1" ] || exit 0

BASENAME="$(basename "$FILE")"

read -r -d '' MSG <<EOF || true
You edited a context file ($BASENAME). This changes your written wiki, but it does NOT
change the ICP score or what other agents read until you sync it into the resolved record.
If Nous is wired in, sync it this turn: get_icp for an ICP or context file, sync_playbook
for a playbook. Do not leave an edited context file unsynced.
EOF

python3 -c 'import json,sys
ctx=sys.stdin.read()
print(json.dumps({"hookSpecificOutput":{"hookEventName":"PostToolUse","additionalContext":ctx},"systemMessage":"Context file edited. Sync it into the resolved record this turn."}))' <<<"$MSG" 2>/dev/null || true
exit 0
