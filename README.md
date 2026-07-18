# GTM OS

**A go-to-market operating system for Claude Code.** Clone it, run `/onboard` once, and Claude learns your business, your ICP, your voice, and your stack. From then on every GTM task it runs (find accounts, score a list, scan for signals, draft a sequence, prep a call) runs on your real context instead of generic guesses.

Built for the people who run go-to-market: founders doing their own outbound, GTM engineers, RevOps leads, and agencies running many client stacks. Free and open, MIT.

---

## Infrastructure

One clone turns Claude Code into a full go-to-market stack. Your business sits in a wiki it reads first, the skills do the work, the hooks keep every action pointed at the truth, an agent runs the whole loop, and your leads live in a database you own.

```
┌────────────────────────────────────────────────────────────┐
│ CLAUDE CODE           the runtime you already have         │
│                                                            │
│   CONTEXT WIKI   context/                                  │
│     your business as an LLM wiki. an index you read        │
│     first, then compiled pages: positioning, ICP,          │
│     voice, pricing. this is what stops it guessing.        │
│                         │                                  │
│   REVENUE CONTEXT LAYER   Nous (optional)                  │
│     your conversations, CRM, and inbox unified into        │
│     one complete picture of every buyer.                   │
│                         │                                  │
│   SKILLS  .claude/skills/    HOOKS  .claude/hooks/         │
│     7 you call by name.        3 run on their own.         │
│     find, enrich, score.       orient, pull, sync.         │
│                         │                                  │
│   AGENT  .claude/agents/                                   │
│     gtm-operator runs the whole account loop.              │
│                         │                                  │
│   LEAD STORE   supabase/                                   │
│     your own Postgres. every lead, its ICP score,          │
│     its signals, your tags. yours to keep, export.         │
└────────────────────────────────────────────────────────────┘
```

The foundation is **Claude Code**, the runtime you already have. Everything above is this repo.

- **Context wiki (`context/`)** is your business as an LLM wiki: positioning, ICP, voice, pricing. An `index.md` a session reads first, so it opens the two pages a task needs instead of loading everything. This is what stops the agent guessing.
- **Revenue context layer (Nous, optional)** brings your conversations, CRM, and inbox into one complete picture of every buyer your agents read from. `/onboard` offers to wire it in. The kit works without it.
- **Skills (`.claude/skills/`)** are the work you call by name. **Hooks (`.claude/hooks/`)** run on their own each session. The **agent (`.claude/agents/`)** chains the skills into the full account loop.
- **Lead store (`supabase/`)** is where your leads live, in a Postgres database you own.

### Supabase manages your leads

Your lead list should live somewhere you own, not locked in a vendor tool. GTM OS keeps it in **your own Supabase Postgres**. You connect your Supabase MCP server, and the agent pushes the ready-made schema (`supabase/schema.sql`) straight into your database, into an existing project or a fresh one, your call. From then on every lead the find-and-enrich skills produce, with its ICP score, its signals, and your tags, lands in a table you own and can export any time.

Ask the OS to show your leads and it renders that table as a shareable page you can open and sort by score, status, or tag. Your pipeline, hosted from your own data.

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
| **7 GTM skills** | onboard, audit, morning-brief, lookalike-builder, company-people, signal-scan, content-scan |
| **3 lifecycle hooks** | pre-wired, no keys: orient each session, pull the record before a task, sync context after an edit |
| **1 agent** | `gtm-operator`, runs the full account-based loop end to end |
| **A context wiki** | your business as an LLM wiki: compiled pages, an index read first, cross-linked |
| **A revenue context layer** | Nous, optional. your conversations, CRM, and inbox as one complete picture of every buyer your agents read from |
| **A lead store you own** | your own Supabase Postgres, holding every lead with its ICP score, signals, and tags |

Everything works on clone. Nothing is required beyond Claude Code.

---

## Skills

| Skill | What it does |
|---|---|
| `/onboard` | Learns your business, fills the context wiki, sets up your lead store. Re-run any time. |
| `/audit` | Scores your build and flags context that has gone stale or thin. Weekly. |
| `/morning-brief` | Pulls your accounts, follow-ups, and what went quiet into one daily brief. |
| `/lookalike-builder` | Paste companies you love. Finds the lookalikes, ICP-scores them, saves the company table to your store. |
| `/company-people` | Finds the decision-maker and a verified email at each company, saved to your store. |
| `/signal-scan` | Scans each account for buying signals, scores them, and writes the score, signals, and a copy-fuel brief to your store. Free. |
| `/content-scan` | Reads a qualified prospect's LinkedIn posts for intent. Paid (Apify), ICP-qualified leads only. |

The find-and-enrich skills interview you the first time you run them and write your answers back into your context, so they come out personalised to your business, not generic, and never ask twice. The rest run on the context wiki you fill at onboarding. The kit ships lean on purpose; you add more as you grow (see `EXPANSIONS.md`).

---

## FAQ

**Do I need to know how to code?** No. You run everything by talking to Claude Code in plain language. The only setup is `/onboard`.

**What is Nous?** The optional revenue context layer underneath the kit. It brings all your sales conversations, CRM data, and inbox into one complete picture of every buyer, so your agents read structured intelligence instead of scattered data, and your team can trust what the agent is doing. It is what your agents read from, not a dashboard you log into.

**Do I need it?** No. The kit works on clone. `/onboard` offers to wire Nous in and everything gets sharper once it is.

**Where do my leads live?** In your own Supabase Postgres, or Airtable, Sheets, or a CSV if you prefer. You own the data either way. Supabase is the recommended path because it renders as a live lead list and holds the ICP score and signals per lead.

**How do I set up Supabase?** Connect your Supabase MCP server, then tell the agent to push `supabase/schema.sql` into your database. It handles the schema, into an existing project or a fresh one. See `supabase/README.md`.

**Do the paid skills cost money?** Some enrichment skills call paid APIs (Apify, AI-Ark, NeverBounce). Each one previews the cost and waits for your yes before spending. The core OS and `signal-scan` are free.

**Is my data private?** Yes. Your business context lives in local files in your repo. Your leads live in a database you own. Nothing is sent anywhere you did not connect.

**I run an agency with many clients. Does that work?** Yes. Each client gets its own folder under `clients/<slug>/` with its own context wiki, so a task for one client reads that client's positioning and voice, never another's. Run `/onboard` for a client to set it up. Your leads all live in one store with a `client` column, so you filter to one client at a time. See `clients/README.md`.

**Can I add my own skills?** Yes. Every skill is built through Claude Code's `skill-creator`, and `EXPANSIONS.md` shows what to add as you grow.

---

## License

MIT. Use it, fork it, build on it. If it makes your go-to-market sharper, that is the point.
