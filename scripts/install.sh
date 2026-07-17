#!/usr/bin/env bash
# install.sh: optional setup helper for GTM OS.
#
# You do not need this to use the kit. The hooks ship pre-wired in .claude/settings.json,
# so a fresh clone works the moment you open it in Claude Code. This script just makes the
# hook scripts executable, checks your machine has what the hooks need, and points you at
# the next move. Safe to re-run.
#
# Usage: ./scripts/install.sh

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

say()  { printf '%s\n' "$*"; }
ok()   { printf '  ok   %s\n' "$*"; }
warn() { printf '  warn %s\n' "$*"; }

say ""
say "GTM OS setup"
say "============"

# 1. Make the hooks executable.
if chmod +x .claude/hooks/*.sh 2>/dev/null; then
  ok "hooks are executable"
else
  warn "could not chmod .claude/hooks/*.sh (are they present?)"
fi

# 2. Check python3 (the hooks use it to emit JSON).
if command -v python3 >/dev/null 2>&1; then
  ok "python3 found ($(python3 --version 2>&1))"
else
  warn "python3 not found. The hooks need it. Install python3 and re-run."
fi

# 3. Confirm the hooks are wired in settings.
if [ -f .claude/settings.json ] && grep -q '"hooks"' .claude/settings.json; then
  ok "hooks are wired in .claude/settings.json"
else
  warn ".claude/settings.json is missing the hooks block. Re-clone or restore it."
fi

# 4. Is the resolved record (Nous) connected as an MCP server?
if command -v claude >/dev/null 2>&1; then
  if claude mcp list 2>/dev/null | grep -qi nous; then
    ok "Nous is connected as an MCP server (the resolved record is live)"
  else
    warn "Nous is not connected yet. The kit works without it, but the record layer is empty."
    warn "Wire it in with: claude mcp add nous <command-or-url>   (see connections.md)"
  fi
else
  warn "the 'claude' CLI is not on PATH, skipping the MCP check"
fi

say ""
say "Next:"
say "  1. Open this folder in Claude Code."
say "  2. Run /onboard once. Have your website ready. Takes 15 to 20 minutes."
say "  3. Run scripts/doctor.sh any time to check the health of your setup."
say ""
