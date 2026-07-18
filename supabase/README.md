# Your lead store

Your lead list should live somewhere you own, not locked inside a vendor tool you rent.
This kit's recommended home is your own **Supabase Postgres**: your database, your rows,
your export, wired into this OS so the skills read and write it directly.

You do not have to use Supabase. Airtable, Google Sheets, or a CSV in `leads/` all work,
and `/onboard` will ask which you prefer. But Supabase is the one the skills target first,
because it gives you a real table you can query, tag, score, and render as a live artifact,
while still owning every row.

## What lives here

- `schema.sql`, the lead store. Two tables (`lead_lists`, `leads`) and one view
  (`lead_list_overview`). Adapted from the Nous leads schema, self-contained. It holds
  identity, firmographics, the ICP score, the signal blocks from `signal-scan` and
  `content-scan`, your tags, and the workflow status.

## Setup, once

The whole point is that you do one thing, and the OS does the rest. Your one job is to
connect your Supabase MCP server. After that, the agent pushes the schema for you.

1. **Add the Supabase MCP server** so this OS can read and write your database directly.
   In Claude Code:

   ```
   claude mcp add supabase -- npx -y @supabase/mcp-server-supabase --project-ref=<your-project-ref>
   ```

   Set the access token it asks for (Supabase, Settings, Access Tokens). Confirm it is
   connected with `claude mcp list`. Save the exact command to `references/supabase-mcp.md`.
   (No Supabase project yet? Create one at supabase.com first, the free tier is plenty.)

2. **Let the agent push the schema.** With the MCP connected, just say: "set up my lead
   store." The agent asks whether to use an existing project or a fresh one, then applies
   `supabase/schema.sql` for you with the MCP `apply_migration`. You never open the SQL
   editor or paste anything. It is safe to re-run.

3. **That is it.** `/onboard` records Supabase as your lead store in `connections.md`, and
   from then on every find-and-enrich skill writes here by default.

## How the OS uses it

- **`lookalike-builder`** discovers lookalike companies and inserts them (one row per
  company, `status = new`).
- **`company-people`** finds the decision-maker and verified email at each company and
  fills in the person (or inserts the lead).
- **`signal-scan`** writes the six signal classes into `leads.signals` and the copy-fuel
  brief into `leads.signal_brief`, and sets `leads.icp_score`.
- **`content-scan`** adds the LinkedIn intent signal into `leads.signals`.
- **Nous (optional).** If the resolved record is connected, it computes the ICP score from
  the signals and pushes it into `leads.icp_score`, so the score in your own database is
  the same one the record uses. The score lives in your table either way.
- **On request** the OS reads the store and renders it as an artifact you can open and sort.

The skills write with plain SQL through the Supabase MCP (`execute_sql`). Nothing is
hard-coded to a hosted service. If you ever leave this OS, the leads are already in a
database you own.

## The shape of a lead

```
name · email · email_status · company · domain · linkedin_url · title
industry · employee_count            (firmographics the ICP scores on)
icp_score (0..100) · icp_reason      (the score, from Nous or a scoring skill)
signals (jsonb) · signal_brief       (from signal-scan / content-scan)
tags (text[]) · status · source · notes   (your workflow)
```

Tag freely (`tags`) to cut the list into segments, and move a lead through
`new -> qualified -> queued -> sent -> replied` as you work it.
