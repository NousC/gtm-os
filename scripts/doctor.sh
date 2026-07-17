#!/usr/bin/env bash
# doctor.sh — health check for a GTM OS build.
#
# Scores the four layers at the file level: is the context filled, is the record wired, is
# the integration registry real, are there actions beyond the defaults. This is the fast
# mechanical check. The deep, judgement-based version is the /audit skill, which reads the
# content of every file and ranks the top fixes. Run this for a quick pulse, run /audit for
# the real review.
#
# Usage: ./scripts/doctor.sh

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

ok()   { printf '  ok    %s\n' "$*"; }
thin() { printf '  thin  %s\n' "$*"; }
miss() { printf '  miss  %s\n' "$*"; }

printf '\nGTM OS doctor\n=============\n\n'

# --- System of Context: are the context/ files real, or still stubs? ---
printf 'Context\n'
CTX_REAL=0; CTX_TOTAL=0
for f in context/*.md; do
  [ -f "$f" ] || continue
  CTX_TOTAL=$((CTX_TOTAL+1))
  # A file is "thin" if it is tiny or still full of (to fill) / placeholder markers.
  BYTES=$(wc -c < "$f" | tr -d ' ')
  if [ "$BYTES" -lt 400 ] || grep -qiE '\(to fill\)|\{\{|\[e\.g\.,|placeholder' "$f"; then
    thin "$f"
  else
    ok "$f"
    CTX_REAL=$((CTX_REAL+1))
  fi
done
printf '  -> %s of %s context files look filled\n\n' "$CTX_REAL" "$CTX_TOTAL"

# --- System of Record: is Nous (or another record) wired in? ---
printf 'Record\n'
if command -v claude >/dev/null 2>&1 && claude mcp list 2>/dev/null | grep -qi nous; then
  ok "Nous connected over MCP (the resolved record is live)"
elif grep -qiE 'nous.*connected|resolved record' connections.md 2>/dev/null; then
  thin "connections.md names a record, but the MCP server is not reachable from here"
else
  miss "no resolved record wired in. Account facts still live scattered across tools."
fi
printf '\n'

# --- System of Integration: how much of the stack is actually connected? ---
printf 'Integration\n'
if [ -f connections.md ]; then
  CONN=$(grep -ciE '\| *connected|in use, connect' connections.md || true)
  NOTYET=$(grep -ci 'not yet connected' connections.md || true)
  ok "connections.md present ($CONN live-ish rows, $NOTYET not yet connected)"
else
  miss "connections.md missing"
fi
printf '\n'

# --- System of Actions: skills, hooks, agents beyond the defaults. ---
printf 'Actions\n'
SKILLS=$(find .claude/skills -name SKILL.md 2>/dev/null | wc -l | tr -d ' ')
HOOKS=$(find .claude/hooks -name '*.sh' 2>/dev/null | wc -l | tr -d ' ')
AGENTS=$(find .claude/agents -name '*.md' 2>/dev/null | wc -l | tr -d ' ')
ok "$SKILLS skills, $HOOKS hooks, $AGENTS agents installed"
if [ -f .claude/settings.json ] && grep -q '"hooks"' .claude/settings.json; then
  ok "hooks wired in .claude/settings.json"
else
  miss "hooks not wired in .claude/settings.json"
fi
printf '\nRun /audit in Claude Code for the deep, content-level review.\n\n'
