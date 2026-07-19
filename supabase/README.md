# Your lead database (your own Clay)

Your lead list should live somewhere you own, not locked inside a vendor tool you rent.
This kit's recommended home is your own **Supabase Postgres**: your database, your rows,
your export, wired into this OS so the skills read and write it directly.

**It is modeled on Clay's waterfall enrichment structure, so you can replace Clay with a
database you own.** The point is not the columns, it is the shape: companies enriched once,
people that point at them, per-field provenance on the data that has to be trusted, and a
log of every provider call so you can see which one won and what it cost.

You do not have to use Supabase. Airtable, Google Sheets, or a CSV in `leads/` all work,
and `/onboard` will ask which you prefer. But Supabase is the one the skills target first,
because it gives you a real database you can query, tag, score, and render as a spreadsheet
you work in, while still owning every row.

## The structure (the Clay principle in shape)

`schema.sql` is four tables plus a spreadsheet view:

- **`companies`**, firmographics enriched **once** per company, not re-fetched for every
  contact. Industry, size, funding, tech stack, job openings, signals, and the company-level
  ICP score. Everyone at that company shares it.
- **`leads`**, people, each pointing at a company (`company_id`). Identity, title, seniority,
  contact channels, and **per-field provenance** on the high-value fields: `email_source`
  (which provider found the email), `email_verified_by`, `last_verified_at`. This is what
  makes the data trustworthy instead of a pile of guesses.
- **`enrichment_events`**, the waterfall log. One row every time a provider is called
  (`provider`, `field`, `status`, `credits`, `ran_at`). This is the table that turns "a lead
  list" into "a Clay replacement": you can see that an email was found by Prospeo, verified by
  NeverBounce, the phone came from a fallback, and compare provider hit-rates and cost.
- **`lead_lists`**, a list or campaign, scoped per client for agencies.
- **`lead_rows`** (view) , one row per lead with the company firmographics and the ICP score
  joined on, best-fit first. This is what you read and render as a table. See `lead-table.md`
  for how to render it as a real spreadsheet.

The waterfall in practice: for email, `company-people` tries provider one, logs an
`enrichment_events` row, stops on a verified hit, else falls through to the next, exactly the
ordered-providers-stop-on-hit pattern that gets you to 80 to 95% coverage instead of 50 to
60% single-source. A re-verify pass reads `last_verified_at` and re-runs the waterfall on
anything stale, the freshness loop Clay charges for.

## The ICP score, and Nous

The score lives in your database (`companies.icp_score`, or per-person on `leads.icp_score`),
so it is always there in the table view. Where does it come from?

- **Set it yourself** in a scoring skill, or
- **Call Nous.** Nous holds your trained ICP scoring model. Connect it and the OS calls Nous
  to score each lead, then writes that score into your table, so the number you see is the one
  the model produced. If you run **multiple clients**, give each client its own **Nous
  workspace** and score that client's leads against their model, then the `client` column here
  keeps each client's leads separate.

Either way the score is visible in every row, and the `client` column scopes the whole
database per agency client, the part Clay charges a lot for.

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
   database." The agent asks whether to use an existing project or a fresh one, then applies
   `supabase/schema.sql` for you with the MCP `apply_migration`. You never open the SQL
   editor or paste anything. It is safe to re-run, and it upgrades an older flat install in place.

3. **That is it.** `/onboard` records Supabase as your lead database in `connections.md`, and
   from then on every find-and-enrich skill writes here by default.

## How the skills fill it (the waterfall)

- **`lookalike-builder`** inserts **companies** (`status = new`, firmographics from AI-Ark).
- **`company-people`** inserts **leads** attached to their company, and runs the **email
  waterfall**: try provider one, log an `enrichment_events` row, stop on verified, else fall
  through. Writes `email`, `email_source`, `email_verified_by`, `last_verified_at`.
- **`signal-scan`** writes `companies.signals` and `companies.icp_score`, shared across that
  company's people.
- **`content-scan`** writes person-level intent into `leads.signals.intent`.
- **Nous (optional)** scores the leads and pushes the score into the table (see above).
- **On request** the OS reads `lead_rows` and renders it as a spreadsheet artifact (`lead-table.md`).

The skills write with plain SQL through the Supabase MCP (`execute_sql`). Nothing is
hard-coded to a hosted service. If you ever leave this OS, the leads are already in a
database you own.
