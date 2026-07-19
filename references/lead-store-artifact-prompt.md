# Lead store artifact: build prompt

A reusable spec for rendering the v2 lead store as a minimal, Google-Sheets-style
spreadsheet artifact. Hand this file to Claude Code with a data pull and it rebuilds the
view. Data-shape-driven, so it works for any workspace. The OS renders this on request, after
the find-and-enrich skills fill the database.

## The one-line ask

> Render my lead store (`companies` + `leads` + `lead_emails` + `enrichment_events`) as one
> self-contained HTML artifact that looks and behaves like a minimal Google Sheets: a dense
> grid, per-client sheet tabs, the enrichment waterfall as provider columns, filters, add
> column, resizable columns, CSV export, and a record drawer.

## Data it reads (one query, embed the result as a JS `DATA` object)

```sql
select l.name, l.title, c.name as company, c.domain, c.industry, c.employee_range as size,
       c.funding_stage as funding, c.revenue_range as revenue,
       l.email, l.email_status, l.email_source, l.email_verified_by as verified_by,
       case when l.last_verified_at is null then null else extract(day from now()-l.last_verified_at)::int end as fresh,
       l.mobile_phone as phone, l.phone_source, l.icp_score, l.status, l.tags, l.client, l.credits_spent as credits,
       coalesce((select json_agg(json_build_object('provider',e.provider,'status',e.status,'email',e.value_found,'credits',e.credits) order by e.ran_at)
                 from enrichment_events e where e.lead_id = l.id and e.field='work_email'), '[]') as wf
from leads l left join companies c on c.id = l.company_id
order by l.icp_score desc nulls last;
```

(For the candidate view, also read `lead_emails` per lead: email, provider, verification, is_primary.)

## Look and feel (non-negotiables)

- **Minimal Google Sheets, not a dashboard.** White ground, hairline grid lines, Arial/system
  sans 13px. No cards, hero, stat tiles, brand dot, or meta legend bar.
- **Two frozen header rows:** a thin grey **column-letter row** (A, B, C and so on) on top,
  then the **field-name row**. **Frozen left:** row-number (`#`) and the **Name** column.
- **Column types colour-coded subtly:** input columns neutral; **enrichment columns carry a
  bolt icon and a purple label**; the ICP column is a blue **formula (f)**. Small header icons
  where they help (mail, phone, check, company, tags).
- **Cells are conditional-format plain:** ICP coloured by tier (green 85 and up, amber 70 to
  84, orange under 70); email shows a status dot plus provider; a stale `verified Nd ago`
  (over 30d) turns amber.
- Theme-aware (light/dark, `prefers-color-scheme` plus `data-theme`).

## Functionality (all client-side, self-contained)

1. **Enrichment waterfall as default columns.** One column per email provider (Prospeo,
   Dropcontact, Apollo, Hunter, Findymail). Each cell shows **the email that provider returned
   plus its verification**: the chosen work email is marked with a star, rejected candidates
   struck through in red (invalid) or amber (risky), misses shown as a dash, providers not
   reached left blank. Hover shows credits. This is the Clay waterfall made visible.
2. **Per-client views as bottom sheet tabs** (Google-Sheets tabs). Generated from the data:
   `All leads`, `My lists` (client null), one tab per distinct `client`. This is where "one
   dashboard per client" lives.
3. **Quick-filter bar** of one-click toggles (Verified email, Has email, Missing email, By
   hand 85 plus, Stale over 30d) plus a field-based filter builder (Stage, Email status, ICP
   tier, Has email, Source) with removable chips.
4. **Resizable columns** by dragging the right edge of any header (`<colgroup>` plus
   `table-layout:fixed`).
5. **Add column:** user adds a custom column with editable cells, included in export.
6. **Column show/hide**, **sort** on any header, **search** across name, company, title,
   email, tags.
7. **CSV export** of the current filtered view (all columns, provider results, custom columns),
   downloaded client-side. Filename carries the view name.
8. **Pagination capped at 100 rows per page** with a `from to of N` pager.
9. **Record drawer:** click a name for a right panel with Company, Contact (email plus
   freshness plus phone, each with provider), Fit and workflow, and the **email waterfall**
   listing each candidate email plus verdict, the chosen one highlighted, titled "work email =
   first verified".

## Build constraints (Artifact CSP)

One file, everything inlined. No external fonts, scripts, images, or fetch. Icons as inline SVG
data URIs or unicode. No doctype/html/head/body wrapper. Wide grid scrolls in its own
container; the page body never scrolls sideways. Keyboard focus plus `Escape` closes the drawer.

## To refresh with live data

Re-run the SQL, replace the embedded `DATA`, republish to the same artifact file path (keeps
the URL). Structure never changes; only the rows do.
