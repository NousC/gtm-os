---
name: lead-list
description: See your lead database as a Clay-style spreadsheet. Reads your lead store (Supabase), injects the data into the fixed canonical template, and publishes it as an artifact, the same clean design for every workspace: airy grid, black line-icon headers, the enrichment waterfall as provider columns with each tool's real logo, per-client tabs, filters, add-column, CSV export, and a record drawer. Use it when the user says "show me my leads", "open my lead list", "render my pipeline", "which leads are qualified", "give me the client dashboard", or "who has intent". For agencies it is one command per client. It renders and lightly manages the store; it does not find or enrich leads (that is lookalike-builder, company-people, signal-scan, content-scan).
---

# Lead list

Turns the lead store into the Clay-style spreadsheet the kit ships. **Do not design a new
artifact.** There is one canonical template, `references/lead-store-template.html`, so every
workspace gets the exact same look. Your job is to pull the data and inject it, not to invent
a layout.

## How it works

1. **Find the store.** Read `connections.md` for the configured lead store. This skill targets
   **Supabase** via the Supabase MCP. If none is set up, point the user at `supabase/README.md`.

2. **Pull the rows.** Run this query (via the MCP `execute_sql`), scoped to what the user asked
   for (a list, a score floor, a client). This produces exactly the shape the template expects,
   including the per-provider email waterfall:

   ```sql
   select l.name, l.title, c.name as company, c.domain, c.industry,
          c.employee_range as size, c.funding_stage as funding, c.revenue_range as revenue,
          l.email, l.email_status, l.email_source, l.email_verified_by as verified_by,
          case when l.last_verified_at is null then null
               else extract(day from now()-l.last_verified_at)::int end as fresh,
          l.mobile_phone as phone, l.phone_source, l.icp_score, l.status, l.tags,
          l.client, l.credits_spent as credits,
          coalesce((select json_agg(json_build_object('provider',e.provider,'status',e.status,
                       'email',e.value_found,'credits',e.credits) order by e.ran_at)
                    from enrichment_events e where e.lead_id = l.id and e.field='work_email'),'[]') as wf
   from leads l left join companies c on c.id = l.company_id
   order by l.icp_score desc nulls last;
   ```

   The template renders per-client tabs from the `client` field on its own, so for an agency
   you pull everything and it splits into a tab per client. To render one client only, add
   `where l.client = '<slug>'`.

3. **Inject and publish.** Read `references/lead-store-template.html`. Replace the placeholder
   `[] /* __LEAD_ROWS__ */` with the query result as a JS array of row objects (each row:
   `{name, title, company, domain, industry, size, funding, revenue, email, email_status,
   email_source, verified_by, fresh, phone, phone_source, icp_score, status, tags, client,
   credits, wf}`). Write the filled file to a working path (for example
   `leads/dashboard.html`, not over the template), then publish it with the Artifact tool.
   Change nothing else in the file. The design, the icons, the embedded provider logos, and
   the behaviour are fixed on purpose.

4. **Hand back the link.** Say it is a snapshot as of now, and to re-run to refresh (the
   template embeds the data, it does not fetch live).

## Manage the store (optional)

When the user asks to tag, re-status, or clean the list, write it back with SQL. Show the row
count a bulk update will touch and confirm before running it. Examples:

```sql
update leads set tags = array_append(tags, 'dream-100') where icp_score >= 85 and not ('dream-100' = any(tags));
update leads set status = 'queued' where status = 'qualified' and icp_score >= 70;
```

## Hard rules

- **One canonical design.** Always render through `references/lead-store-template.html`. Never
  hand-build a different layout, never restyle it. Everyone gets the same artifact.
- **The store is the source of truth, the artifact is a snapshot.** State the "as of" time and
  offer to regenerate.
- **Confirm bulk writes** (show the count).
- **Do not find or enrich here.** Route to the right skill and stop.
- **Provider logos** are already embedded in the template. If the user drops crisper SVGs in
  `references/logos/`, swap them into the template's logo block, otherwise leave the shipped
  marks.

## What runs around this

`lookalike-builder` and `company-people` fill the store; `signal-scan` and `content-scan`
enrich it; `lead-list` (this) is how you and your clients see it.
