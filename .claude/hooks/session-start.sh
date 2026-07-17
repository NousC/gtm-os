#!/usr/bin/env bash
# session-start.sh: SessionStart hook.
#
# Orients every fresh Claude Code session on the system it is running inside, so it
# reaches for the context files and the resolved record before it acts, instead of
# answering from generic knowledge. This is the bootstrap hook: the equivalent of their
# skill-loader, but ours orients on the system and the record, not a list of skills.
#
# Pure local. No API keys, no network. Emits additionalContext as JSON on stdout.
# Always exits 0 so it can never block a session.

set -euo pipefail

read -r -d '' MSG <<'EOF' || true
GTM OS is live in this workspace. You run on The Agentic GTM System: Actions, Context,
Record, Integration, with one resolved record underneath all four.

Before any go-to-market task, read the relevant file in context/ and pull the resolved
record first. The context/ files are the user's own business wiki (who they sell to, how
they talk, what they charge). The resolved record is the live, per-account version of
that truth: every person, company, conversation, and signal across the stack, resolved
into one record. If Nous is wired in (see connections.md), that record is Nous, reached
over MCP.

Rules that keep the OS honest:
- Do not guess from generic knowledge when a context file or the record holds the truth.
- If you learn a fact about an account, record it so the next session starts from truth.
- If you edit a context or playbook file, sync it into the record the same turn, or the
  score and what other agents read will not change.
EOF

python3 -c 'import json,sys; print(json.dumps({"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":sys.stdin.read()}}))' <<<"$MSG" 2>/dev/null || true
exit 0
