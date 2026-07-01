# Expansions: what to add as you grow

The kit ships lean on purpose. Four skills, the context files, the intel layer, two reference docs, one framework. That is it. As you use it, you will outgrow the base. This guide says what to add, when, and why.

Your OS should look like a small, well-run go-to-market team. Not a hoarder's basement.

---

## What ships (do not remove)

| Folder / file | Purpose |
|---|---|
| `context/` | The files that make the OS yours. Filled by `/onboard`. |
| `references/` | Voice samples, docs you bring, and tool API guides as you wire them. |
| `connections.md` | Every tool the OS can reach. |
| `intel/` | Where the OS gets smarter over time: `decisions/`, `views/`, `meetings/`, `sources/`, `patterns.md`. See `intel/README.md`. |
| `archives/` | Old files. Move here, never delete. |
| `.claude/skills/` | `/onboard`, `/audit`, `/morning-brief`, `/intel`. Add more as you grow. |
| `.claude/agents/` | Your first agent goes here. |
| `intake.md` | Source of truth for `/onboard`. Edit and re-run any time. |
| `CLAUDE.md` | Root operating manual. Filled by `/onboard`. |

---

## What to add as you grow

| Add | When | Why |
|---|---|---|
| `context/icp/` (a folder) | Your ICP splits into several distinct segments | When one `icp.md` stops holding it, give each segment its own file |
| A list-building skill | You build lead lists by hand more than twice | Find and Score from the playbook, made repeatable |
| A signal-scan skill | You research accounts before reaching out | Turns the Signal stage into one command |
| An outreach skill | You draft sequences regularly | Personalise from the playbook, in your voice |
| A meeting-brief skill | You prep for calls one by one | Pulls the resolved record into a pre-call brief |
| `.claude/agents/` | You need a multi-step motion run end to end | An agent chains the skills, like the full Dream 1000 loop |
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
