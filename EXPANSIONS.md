# Expansions: what to add as you grow

The kit ships lean on purpose. Four skills, the context files, the intel layer, two reference docs, one framework. That is it. As you use it, you will outgrow the base. This guide says what to add, when, and why.

Your OS should look like a small, well-run go-to-market team. Not a hoarder's basement.

---

## What ships (do not remove)

| Folder / file | Purpose |
|---|---|
| `context/` | The context wiki: `index.md` (the read-first catalog) plus the pages that make the OS yours. Filled by `/onboard`. Every page carries frontmatter and a `**Hubs:**` footer. |
| `references/` | Voice samples, docs you bring, and tool API guides as you wire them. |
| `connections.md` | Every tool the OS can reach. |
| `intel/` | Where the OS gets smarter over time: `decisions/`, `views/`, `meetings/`, `sources/`, `patterns.md`. See `intel/README.md`. |
| `archives/` | Old files. Move here, never delete. |
| `.claude/skills/` | `/onboard`, `/audit`, `/morning-brief`, `/intel`, `/signal-scan`, `/content-scan`. Add more as you grow. |
| `templates/` | Reusable scaffolds (campaigns, email sequences, message frames). The OS files new ones here and reads from here when it drafts. See `templates/README.md`. |
| `.claude/hooks/` | Three lifecycle hooks (orient, pull-record-before-task, sync-after-edit), wired in `.claude/settings.json`. See `.claude/hooks/README.md`. |
| `.claude/agents/` | `gtm-operator`, the first real agent, runs the Dream 1000 loop over the record. Add more as your motions harden. |
| `scripts/` | `install.sh` (optional setup) and `doctor.sh` (fast four-layer health check). |
| `intake.md` | Source of truth for `/onboard`. Edit and re-run any time. |
| `CLAUDE.md` | Root operating manual. Filled by `/onboard`. |

---

## What to add as you grow

| Add | When | Why |
|---|---|---|
| `context/icp/` (a folder) | Your ICP splits into several distinct segments | The wiki's compounding pattern: promote the page to a folder, `icp.md` stays the spine every skill reads, dated `MMYY-topic.md` files hold the depth. Update `context/index.md` when you do |
| A list-building skill | You build lead lists by hand more than twice | Find and Score from the playbook, made repeatable |
| A signal-scan skill | You research accounts before reaching out | Turns the Signal stage into one command |
| An outreach skill | You draft sequences regularly | Personalise from the playbook, in your voice |
| A meeting-brief skill | You prep for calls one by one | Pulls the resolved record into a pre-call brief |
| More agents next to `gtm-operator` | You run a second distinct motion end to end | The first agent ships. Add a sibling when a new motion (inbound triage, renewals) needs its own end-to-end run |
| A hook of your own | An action keeps needing to stay pointed at the record | Orient, pull, sync, or capture. If it just fires data at a tool, that is a job for the record, not a hook. See `.claude/hooks/README.md` |
| `references/{tool}-api.md` | You wire a new API or MCP | Researched once, saved forever. Future skills do not re-research it |
| `scripts/` | You hit an API no MCP covers | Most second connections are a script, not an MCP |

---

## The rule for every new skill

The skills are the product. Build every one through Claude Code's `skill-creator` plugin: Create, then Eval against real prompts, then Improve from what the eval shows. Never hand-write a skill and ship it. A skill that has not been run through Eval is a draft. This holds for the four skills that ship in the kit and every one you add after.

---

## How to tell when it is time to add

Ask three questions:

1. Is this conceptually new, or does it fit somewhere that already exists?
2. Will I touch it three or more times in the next month?
3. Could a future skill route into it naturally?

Two yeses, add it. One yes, wait.

---

## What not to add

- Do not dump raw email or Slack archives into `references/`. Interpreted facts only.
- Do not build a folder of folders for the sake of tidiness. Flat with good names beats deep nesting.
- Do not add `notes/`, `misc/`, `tmp/`, or `inbox/`. They become graveyards. Use `archives/` if it is old, write a real file in the right place if it is new.
- Do not pre-create folders you do not need yet. Empty folders are noise.
- Do not fork your operating manual. One `CLAUDE.md` at the root.

> Your OS should look like a small, well-run go-to-market team. When you cannot find something, that is a signal to consolidate, not to add another folder.
