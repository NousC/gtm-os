#!/usr/bin/env bash
# gtm-task-context.sh — UserPromptSubmit hook.
#
# When the user's prompt looks like a go-to-market task, inject a short reminder to pull
# the resolved record and read the context files before acting, and to record what was
# learned afterward. On anything that does not look like GTM work, it stays silent.
#
# This is the inversion of their model: their PostToolUse hooks fire REST calls at tools;
# this one shapes the agent so its next action runs on real context instead of a guess.
#
# Pure local. No API keys, no network. Always exits 0.

set -euo pipefail

INPUT="$(cat 2>/dev/null || true)"
PROMPT="$(printf '%s' "$INPUT" | python3 -c 'import json,sys;
try:
    print(json.load(sys.stdin).get("prompt",""))
except Exception:
    print("")' 2>/dev/null || true)"

# Only fire on GTM-shaped prompts. Keep the net wide but not universal.
if ! printf '%s' "$PROMPT" | grep -qiE 'account|prospect|lead|outreach|cold email|campaign|sequence|meeting|call prep|icp|follow[ -]?up|reply|list|score|pipeline|outbound|brief me|who is'; then
  exit 0
fi

read -r -d '' MSG <<'EOF' || true
This looks like a go-to-market task. Before you act, read the relevant context/ file and
pull the resolved record: get_context with the person's email and the matching intent, or
get_account for the whole record. Prefer the resolved record over generic knowledge. After
you help, record what you learned so the next session starts from truth.
EOF

python3 -c 'import json,sys; print(json.dumps({"hookSpecificOutput":{"hookEventName":"UserPromptSubmit","additionalContext":sys.stdin.read()}}))' <<<"$MSG" 2>/dev/null || true
exit 0
