# GTM OS

**A go-to-market operating system for Claude Code.** Clone it, run `/onboard` once, and Claude learns your business, your ICP, your voice, and your stack. From then on every GTM task it runs (find accounts, score a list, scan for signals, draft a sequence, prep a call) runs on your real context instead of generic guesses.

Built for the people who run go-to-market: founders doing their own outbound, GTM engineers, RevOps leads, and agencies running many client stacks. Free and open, MIT.

---

## Quickstart

```bash
git clone https://github.com/NousC/gtm-os.git
cd gtm-os
claude          # open the folder in Claude Code
```

Then, inside Claude Code:

```
/onboard
```

`/onboard` interviews you for about fifteen minutes (talk it through with dictation if you like), scrapes your website, and fills your context. Have your site URL ready, and point it at anything you already have (old positioning, an ICP sheet, a few real emails). That is the whole setup. Bring a real account and start working.

---

## What you get

| | |
|---|---|
| **9 GTM skills** | onboard, audit, morning-brief, intel, lookalike-builder, company-people, signal-scan, content-scan, lead-list |
| **3 lifecycle hooks** | pre-wired, no keys: orient each session, pull the record before a task, sync context after an edit |
| **1 agent** | `gtm-operator`, runs the full account-based loop end to end |
| **A context wiki** | your business as an LLM wiki: compiled pages, an index read first, cross-linked |
| **A lead store you own** | your own Supabase Postgres, holding every lead with its ICP score, signals, and tags |

Everything works on clone. Nothing is required beyond Claude Code.

---

## How it is built

Three layers, bottom to top:

**1. The foundation, Claude Code.** The runtime you already have. GTM OS is what you drop into it.

**2. The OS, this repo.** The infrastructure that makes Claude act like it knows your business:

- **The context wiki (`context/`)** is where your business lives: positioning, ICP, messaging, voice, competitors, pricing. It is an LLM wiki, not a folder of files, compiled pages with an `index.md` a session reads first, so it opens the two pages a task needs instead of loading everything. This is what stops the agent guessing.
- **The skills (`.claude/skills/`)** are the work, called by name. Find and enrich leads, scan for signals, brief a call, audit the build.
- **The hooks (`.claude/hooks/`)** run on their own, keeping every action pointed at the truth: orient each session, pull the record before a GTM task, sync a context change back in.
- **The agent (`.claude/agents/`)** chains the skills into the full loop when you want it run end to end.
- **The lead store (`supabase/`)** is where your leads live, in a database you own.

**3. The resolved record, Nous (optional).** Your context wiki is what is true about *you*. The resolved record is what is true about *everyone else*: every person, company, conversation, and reply across your CRM, inbox, LinkedIn, and meetings, resolved into one live account and scored on your real outcomes. **Nous** is built to be that record. `/onboard` offers to wire it in and syncs your ICP into it, so your files score real accounts. The kit works without it; it gets sharper with it.

### Supabase manages your leads

Your lead list should live somewhere you own, not locked in a vendor tool. GTM OS keeps it in **your own Supabase Postgres**. You connect your Supabase MCP server, and the agent pushes the ready-made schema (`supabase/schema.sql`) straight into your database, into an existing project or a fresh one, your call. From then on every lead the find-and-enrich skills produce, with its ICP score, its signals, and your tags, lands in a table you own and can export any time.

Run `/lead-list` and the OS renders that table as a shareable page you can open and sort by score, status, or tag. Your pipeline, hosted from your own data.

---

## Skills

| Skill | What it does |
|---|---|
| `/onboard` | Learns your business, fills the context wiki, sets up your lead store. Re-run any time. |
| `/audit` | Scores your build and flags context that has gone stale or thin. Weekly. |
| `/morning-brief` | Pulls your accounts, follow-ups, and what went quiet into one daily brief. |
| `/intel` | Turns the week's meetings, decisions, and sources into durable insight. Weekly. |
| `/lookalike-builder` | Paste companies you love. Finds the lookalikes, ICP-scores them, saves the company table to your store. |
| `/company-people` | Finds the decision-maker and a verified email at each company, saved to your store. |
| `/signal-scan` | Scans each account for buying signals, scores them, and writes the score, signals, and a copy-fuel brief to your store. Free. |
| `/content-scan` | Reads a qualified prospect's LinkedIn posts for intent. Paid (Apify), ICP-qualified leads only. |
| `/lead-list` | Renders your lead store as a sortable page and helps you tag, re-status, and filter it. |

Every skill interviews you the first time you run it, so it comes out personalised to your business, not generic. The kit ships lean on purpose; you add more as you grow (see `EXPANSIONS.md`).

---

## FAQ

**Do I need to know how to code?** No. You run everything by talking to Claude Code in plain language. The only setup is `/onboard`.

**Do I need Nous?** No. The kit works on clone. Nous is the optional resolved-record layer underneath; `/onboard` offers to wire it in and everything gets sharper once it is.

**Where do my leads live?** In your own Supabase Postgres, or Airtable, Sheets, or a CSV if you prefer. You own the data either way. Supabase is the recommended path because it renders as a live lead list and holds the ICP score and signals per lead.

**How do I set up Supabase?** Connect your Supabase MCP server, then tell the agent to push `supabase/schema.sql` into your database. It handles the schema, into an existing project or a fresh one. See `supabase/README.md`.

**Do the paid skills cost money?** Some enrichment skills call paid APIs (Apify, AI-Ark, NeverBounce). Each one previews the cost and waits for your yes before spending. The core OS and `signal-scan` are free.

**Is my data private?** Yes. Your business context lives in local files in your repo. Your leads live in a database you own. Nothing is sent anywhere you did not connect.

**Can I add my own skills?** Yes. Every skill is built through Claude Code's `skill-creator`, and `EXPANSIONS.md` shows what to add as you grow.

---

## License

MIT. Use it, fork it, build on it. If it makes your go-to-market sharper, that is the point.
