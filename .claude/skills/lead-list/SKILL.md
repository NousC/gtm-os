---
name: lead-list
description: See and work your lead store as a visual list. Reads the leads from your own store (Supabase, or Airtable/Sheets/CSV), renders them as a shareable artifact you can open and sort (ICP score, status, tags, signals, email status), and helps you manage the list: tag a segment, move leads through the pipeline, filter to the warmest. Use it when the user says "show me my leads", "open my lead list", "render my pipeline", "which leads are qualified", "tag these as X", or "who has intent". It reads and writes the store; it does not find or enrich leads (that is lookalike-builder, company-people, signal-scan, content-scan).
---

# Lead list

## What it does

Turns your lead store into something you can look at and work. Two jobs:

1. **View.** Read the leads and render them as an artifact: a sortable table with the ICP
   score, status, tags, email status, and the signals each lead carries. A snapshot you can
   open, sort, and share.
2. **Manage.** Tag a segment, move leads through the pipeline (`new -> qualified -> queued ->
   sent -> replied -> dropped`), or filter the list, by writing back to the store.

It does not find or enrich leads. `lookalike-builder` and `company-people` fill the store,
`signal-scan` and `content-scan` enrich it, and this skill is how you see and work what is
there.

## The store

Read `connections.md` for the configured store. **Supabase (recommended)** via the Supabase
MCP: read `lead_list_overview` (already sorted best-fit first) or query `leads` directly. For
**Airtable / Sheets / CSV**, read the configured table or the CSV in `leads/`. If nothing is
set up, point the user at `supabase/README.md` to create their own store first.

## View: render the artifact

1. **Read the leads.** Pull the list the user asked for (a named list, the whole store, or a
   filter like "qualified" or "has-intent"). With Supabase:
   ```sql
   select * from lead_list_overview
   where icp_score >= 70          -- or list = '<name>', or 'has-intent' = any(tags)
   order by icp_score desc nulls last
   limit 500;
   ```
2. **Build the page.** Load the `artifact-design` skill first (it calibrates the design), then
   write a self-contained HTML file and publish it with the Artifact tool. The page embeds the
   leads it read as data (an artifact cannot fetch live, the CSP blocks it, so it is a
   point-in-time snapshot, regenerate to refresh). The table should carry, per lead:
   - name, title, company, domain (domain and linkedin_url as links)
   - **ICP score** as the lead visual: a 0 to 100 value with a small bar or color band, sorted high first
   - email plus email_status (verified / risky / invalid, color-coded)
   - status and tags (as chips)
   - the top signal or the `has-intent` flag, with the fuller signals available on hover or a detail row
   - a header line: list name, count, and how many cleared the ICP threshold
   Make it sortable by score and status, readable in light and dark, and it must not scroll the
   body horizontally (wrap the table in an `overflow-x: auto` container).
3. **Hand back the link** and say it is a snapshot as of now, re-run to refresh.

## Manage: write back to the store

When the user asks to tag, re-status, or clean the list, write it back. Supabase examples:

```sql
-- tag a segment
update leads set tags = array_append(tags, 'dream-100')
where icp_score >= 85 and not ('dream-100' = any(tags));

-- move qualified leads into the send queue
update leads set status = 'queued' where status = 'qualified' and icp_score >= 70;

-- drop the ones that do not fit
update leads set status = 'dropped' where icp_score < 50;
```

Show the user what the change will touch (a count) before running a bulk update, and confirm
before anything destructive. For Airtable / Sheets, make the equivalent field edits.

## Hard rules

- **The store is the source of truth, the artifact is a snapshot.** Never treat the rendered
  page as live. State the "as of" time and offer to regenerate.
- **Confirm bulk writes.** Show the row count a bulk `update` will touch and get a yes.
- **Do not find or enrich here.** If the user wants more leads or more signal, route to the
  right skill and stop.
- **The store is the user's own database.** Read and write only what they configured, never a
  vendor they do not control.

## What runs around this

- `lookalike-builder` -> `company-people` fill the store with companies and decision-makers.
- `signal-scan` -> `content-scan` enrich each lead with signals and the ICP score.
- `lead-list` (this) is how you see and work the result, then hand the qualified segment to
  your outreach skill.
