# Hooks: the OS acts without being asked

A skill runs when you call it. A hook runs on its own, on a Claude Code lifecycle event.
That is the difference between an OS you drive and an OS that is already oriented when you
sit down. These four hooks make the system act on its own principles without you
remembering to.

They ship pre-wired in `.claude/settings.json`, so a fresh clone has them the moment you
open it in Claude Code. No install step. Three are pure local bash — no keys, no network.
The fourth (`nous-context-sync.sh`) pushes an edited context file straight into Nous when
you are connected, and no-ops silently when you are not. Every one exits cleanly even if
something goes wrong, so a hook can never block your session.

## The four

| Hook | Fires on | What it does |
|---|---|---|
| `session-start.sh` | SessionStart | Orients the session on the four-layer system and tells it to read the context files and pull the resolved record before acting. |
| `gtm-task-context.sh` | UserPromptSubmit | When your prompt looks like a GTM task, reminds the agent to pull the resolved record (get_context / get_account) first and record what it learned after. Silent on everything else. |
| `nous-context-sync.sh` | PostToolUse (Edit / Write) | When you edit a `context/*.md` file, pushes it straight into Nous (file → graph) via `scripts/nous-sync-context.mjs`, so your ICP / positioning / pricing is ALWAYS the current file — you never have to say "sync my ICP". Reads your key from `NOUS_API_KEY` or `~/.nous/config.json`; no-ops if Nous isn't connected. |
| `context-sync-nudge.sh` | PostToolUse (Edit / Write) | The soft backstop for **playbooks** (which have no auto-sync): reminds the agent to call `sync_playbook` after editing one, since the change is inert until synced. |

## Why ours write to the brain, not to the pipes

The obvious way to build GTM hooks is the way most kits do it: fire a REST call at a tool
when Claude finishes. Enrich in Apollo, log in Notion, push to Lemlist. That is thirty
hooks hitting seventeen tools, each one a disconnected slice, nothing resolving
underneath. It is a lot of plumbing running on empty context, and it is the exact problem
this kit exists to fix.

So our hooks do the opposite. They do not push data out to dumb pipes. They pull the
resolved record in before the agent acts, and push what the agent learned back into it
after. The record is the brain. The hooks keep every action pointed at it.

That is also why there are three, not thirty. The tools you send through (email, LinkedIn,
your CRM) connect through the resolved record, not through a hook per tool. The record is
your System of Integration. A hook per REST endpoint would be rebuilding, badly, the layer
you already have underneath.

## Turning one off

Delete its block from `.claude/settings.json`, or delete the script. They are independent.
Restart your Claude Code session for the change to take effect. Run `scripts/doctor.sh` to
confirm what is wired.

## Writing your own

A GTM OS hook earns its place when it keeps an action pointed at the record: orient the
session, pull context before a task, sync a change back, capture a fact. If the hook you
are about to write just fires data at a tool with nothing resolving underneath, that is a
job for the resolved record, not a hook. Keep the set small. Three well-aimed hooks beat
thirty that guess.
