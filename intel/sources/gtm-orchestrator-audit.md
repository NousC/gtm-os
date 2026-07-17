# Source: go-to-market-orchestrator (janskuba) — a teardown

Distilled read of `github.com/janskuba/go-to-market-orchestrator`, done to decide what GTM
OS should learn from it. Kept here because it is the clearest example of the opposite
design choice to ours, and the contrast is what sharpened this kit.

## What it is

A Claude Code kit built action-first. Its whole weight sits in two layers of our four:
Actions and Integration. It ships:

- **30 hooks** across 8 categories, firing on Claude Code lifecycle events (Stop,
  PostToolUse, SessionStart, SessionEnd, Notification).
- **A Python orchestrator** (`run.sh` -> `dispatch.py` -> `py/<service>.py`) that routes a
  hook payload to one of ~17 REST handlers (Slack, Apollo, HubSpot, Attio, Lemlist,
  Instantly, Smartlead, Clay, Notion, Figma, Linear, Sheets, Airtable, Zapier/n8n/Make).
- **7 subagents** chained by a `/outbound-pipeline` command with checkpoint CSVs between
  stages (signal-scraper -> lead-prioritizer -> prospect-profiler -> hook-writer ->
  sequence-builder).
- **6 skills** (campaign-builder, lead-enrichment, personalization-writer,
  pipeline-reviewer, reply-classifier, signal-monitor) built from shared `modules/` and
  `templates/`.
- **5 role-based `settings.json` packs** (founder, sales, marketing, ops, design).
- **A real install layer**: `install.sh` (copy or symlink, cherry-pick hooks, backup
  settings), `validate.sh` (schema-check + compile + dry-run every handler), `uninstall.sh`.
- **`DRY_RUN=1`** on every handler so you can smoke-test without side effects.

The engineering is clean. The single-contract dispatch (`payload["action"]` drives every
handler, CLI arg overrides stdin) is genuinely tidy. The install DX is better than most.

## The hole in the middle

It has no System of Record and no System of Context. It fires actions straight at 17
tools with nothing resolving underneath. Enrich in Apollo, log in Notion, push to
Lemlist, and each of those is a disconnected slice. It is a live demonstration of the
exact problem this kit opens on: Record becomes ten disconnected tools, Context is a
static doc that never meets a real account, and Actions guess. Impressive plumbing
running on empty context.

## What we took from it

1. **Hooks as a surface.** The best idea in the repo. Lifecycle hooks let the OS act
   without the user remembering to run a skill. We adopted the mechanism and inverted the
   purpose: their hooks push to dumb pipes, ours write to the brain (orient the session,
   pull the record before a task, sync context back into the record). No API keys, no
   REST. See `.claude/hooks/README.md`.
2. **Install and doctor DX.** We added `scripts/install.sh` and `scripts/doctor.sh`, but
   kept hooks pre-wired in `.claude/settings.json` so a fresh clone works with zero install.
3. **One real orchestration agent.** Their `/outbound-pipeline` chained agents over CSVs.
   We shipped one Nous-native agent (`.claude/agents/gtm-operator.md`) that runs the same
   Dream 1000 loop over the resolved record instead of files.

## What we rejected, on purpose

- **The 17 REST handlers.** Nous is our System of Integration and Record. Re-implementing
  tool-by-tool REST calls with no record underneath is the thing we exist to replace. The
  moat is in resolving the N accounts into one record, not in one more Apollo POST.
- **Role-based settings packs as separate files.** Our hook set is three and ships wired.
  Motion-specific tailoring lives in onboarding instead.
- **Content-prompt library.** Off-core for this kit.

## The one-line takeaway

They built the hands. We built the brain. The hands are a weekend of REST calls; the
resolved record and the written context that stop those actions guessing are the part
that is hard to rebuild. Learn the hook mechanism, keep the thesis.
