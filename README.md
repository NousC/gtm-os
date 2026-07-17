# GTM OS: a go-to-market operating system for Claude Code

A free, open starter kit that turns Claude Code into your go-to-market operating system. You clone it, run `/onboard` once, and Claude learns your business, your ICP, your voice, and your stack. From then on every GTM task it does for you (research an account, build a list, draft a sequence, prep a call, write a brief) runs on your real context instead of generic guesses.

It is built for the people who run go-to-market: founders doing their own outbound, GTM engineers, RevOps leads, and agencies running many client stacks.

---

## The idea in one line

> Your agents are only as good as the context they can reach. GTM OS gives them one place to reach it.

Most GTM stacks scatter the truth about an account across ten tools, so the agent guesses. This kit puts your context in writing, connects it to a live record of every account, and lets every skill act on the whole picture.

---

## The two things to read first

Two reference files sit at the root. Read them before you do anything else. They are the knowledge layer, not config.

- **`THE-AGENTIC-GTM-SYSTEM.md`**: the architecture. Four layers (Actions, Context, Record, Integration) and the one resolved record underneath them.
- **`THE-GTM-PLAYBOOK.md`**: the motion. The end-to-end account-based loop that runs on top: Find, Signal, Score, Personalise, Send, Reply, Learn.

Architecture first, then the motion. Once both make sense, the folder structure stops looking like folders and starts looking like a system.

---

## Quick start

1. **Clone the repo** into a working folder.
2. **Open it in Claude Code** and run `/onboard`. Have your website ready. If you use Wispr Flow or any dictation, just talk through the answers. If you already have positioning docs, an ICP, a deck, or old emails, point Claude at them. The more raw material you give it, the better the result. Takes about 15 to 20 minutes.
3. **`/onboard` scaffolds your context.** It scrapes your site, merges that with what you said, and fills the `context/` files and `connections.md`. You review and correct.
4. **Connect your stack.** `/onboard` shows where your tools slot into the System of Record and Integration, and offers to wire in the resolved record underneath (see below).
5. **Use it.** Bring real accounts and real tasks. Run `/audit` after a week to see where the context is thin or stale. Run `/morning-brief` to get the day pulled together for you.

---

## What ships

Four skills, three hooks, one agent. Kept lean on purpose. You add more as you grow (see `EXPANSIONS.md`).

**Four skills**, the work you call by name:

| Skill | When to run |
|---|---|
| `/onboard` | Day one, right after clone. Asks about you, your ICP, your voice, and your stack, scrapes your site, scaffolds the `context/` files, and syncs your ICP into the resolved record. Re-run any time after editing `intake.md`. |
| `/audit` | After a week, then weekly. Scores your build against the four layers and flags context that has gone stale or thin. |
| `/morning-brief` | Daily. Pulls your accounts, your follow-ups, and what went quiet into one brief so you start the day already oriented. |
| `/intel` | Weekly. Turns the week's internal meetings, decisions, and saved sources into durable insight in the `intel/` layer. |

**Three hooks**, the work that runs on its own. They ship pre-wired in `.claude/settings.json`, so a fresh clone has them the moment you open it. No keys, no network. One orients each new session, one reminds the OS to pull the record before a GTM task, one reminds it to sync a context file back into the record after you edit it. Where most GTM kits fire hooks *out* at a dozen tools, ours point every action back *in* at the record. See `.claude/hooks/README.md`.

**One agent**, `gtm-operator`, the first real one. It runs the full Dream 1000 loop over the resolved record instead of over scratch files. Reach for it when the whole motion needs running, not a single step.

A one-shot `scripts/install.sh` makes the hooks executable and checks your setup, and `scripts/doctor.sh` gives you a fast health read on the four layers. Neither is required. The kit works on clone.

---

## The context wiki

The heart of the kit, and it is a wiki, not a folder of files. It runs on the LLM wiki pattern: compiled pages with an index you read first, so a fresh session opens the two pages a task needs instead of loading everything. `/onboard` fills it from your answers and your website.

```
context/
├── index.md           the catalog. read first. one line per page.
├── about-me.md        you, your story, what you have built
├── positioning.md     what you sell and why it matters
├── icp.md             the company profile and the buyer inside it
├── messaging.md       how you frame the problem and the proof
├── voice-and-tone.md  how you actually talk, with examples in references/
├── competitors.md     who you are measured against and your wedge
└── pricing.md         what you charge and how
```

Three layers sit under it. **Sources** (`references/`, and anything you bring: voice samples, a deck, a pricing sheet) are the raw material, and you own them. **The wiki** (`context/`) is compiled pages, one claim each, and the OS owns them. **The schema** (`CLAUDE.md`) is the rules. Every page carries frontmatter and a `**Hubs:**` footer that links the pages it builds on, so the wiki is queryable and cross-linked, and `/audit` can lint it for stale claims, orphans, and pages with no source behind them.

One rule holds it together: **the wiki is about you, the record is about them.** Your positioning, ICP, and voice live in these files. Accounts, people, and signals live in the resolved record. An account fact never goes in a context page, and positioning never goes in the record except through the sync tools. Your raw voice samples (real emails, posts, pages, unedited) live in `references/voice-samples/`, and `voice-and-tone.md` is the distilled read of them.

---

## The resolved record underneath

There are two halves to this system and they do different jobs. The `context/` files are your own wiki: who you sell to, how you talk, what you charge. You write them, you own them, they are yours. The other half is what happens inside your tools, the part a static file can never hold: every person, company, conversation, and reply across your CRM, your inbox, LinkedIn, and your meetings, resolved into one live record per account and scored on your real outcomes. That half is the resolved record.

**Nous is built to be that record.** It connects your GTM tools, resolves every person and company into one live record, structures it into context your agents can read, and serves the whole account in a single call. Your files teach the system who you are. The record teaches it who everyone else is. Neither pays off alone: your ICP is words in a file until the record scores real accounts against it, and the record is raw activity until your context says what it means. The kit works without Nous, and wherever these files say "the resolved record" or "the context graph" that is the job it does. `/onboard` will offer to wire it in, then sync your ICP into it. It is an option, not a requirement.

---

## Repo layout

```
gtm-os/
├── README.md
├── CLAUDE.md                   your operating manual, filled by /onboard
├── intake.md                   the source of truth for /onboard, edit and re-run any time
├── THE-AGENTIC-GTM-SYSTEM.md   reference: the architecture
├── THE-GTM-PLAYBOOK.md         reference: the motion
├── EXPANSIONS.md               what to add as you grow
├── connections.md              registry of every tool your OS can reach
├── context/                    the context wiki: index.md (read first) + the pages that make it yours
├── references/                 voice samples and any docs you bring
├── intel/                      where the OS gets smarter over time
│   ├── decisions/log.md        append-only record of what you decided and why
│   ├── views/                  how a belief or number drifted over time, dated
│   ├── meetings/               internal team and co-founder notes, distilled
│   ├── sources/                external resources worth keeping, distilled
│   └── patterns.md             recurring themes across meetings, sources, accounts
├── archives/                   old files, do not delete, move here
├── scripts/                    install.sh (optional setup) + doctor.sh (health check)
└── .claude/
    ├── settings.json           wires the hooks, ships ready on clone
    ├── skills/                 onboard, audit, morning-brief, intel
    ├── hooks/                  three lifecycle hooks that keep actions pointed at the record
    └── agents/                 gtm-operator, the first real agent (runs the Dream 1000 loop)
```

---

## License

MIT. Use it, fork it, build on it. If it makes your go-to-market sharper, that is the point.
