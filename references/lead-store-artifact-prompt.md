# Lead store artifact: build prompt

The canonical, shipped render is the fixed template **`references/lead-store-template.html`**,
and the **`/lead-list`** skill fills it with your data and publishes it, so every workspace gets
the exact same design. Do not rebuild the artifact from scratch in normal use; inject the data
into the template. This file documents how that template is built and behaves, so the design is
recorded and a rare from-scratch rebuild reproduces it. Data-shape-driven, so it works for any
workspace.

## The one-line ask

> Render my lead store (`companies` + `leads` + `lead_emails` + `enrichment_events`) as one
> self-contained HTML artifact that looks and behaves like Clay's table view: an airy grid with
> black line-icon headers and a checkbox column, per-client bottom tabs, the enrichment
> waterfall as provider columns showing each tool's real logo, filters, add
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

## Look and feel (Clay, not a dashboard)

The reference is Clay's table view. Match it, minus the Clay logo.

- **A Clay grid, not Google Sheets.** White ground, hairline grid lines, system sans 13px. No
  cards, hero, stat tiles, brand dot, or legend bar. And **no A/B/C column-letter row**, that
  is Sheets; this is Clay.
- **Taller, airy rows** (about 40px), roomy like Clay, not a cramped spreadsheet.
- **A monochrome black line-icon in every column header**, stroke-only, dark, no purple
  (building for company, people for size, mail for email, shield for verified, clock for
  freshness, target for ICP, tag for tags, coin for credits). Small and consistent.
- **A dark rounded glyph in the first cell**, a small building tile before each name, like
  Clay's per-row company mark.
- **A checkbox and row-number column** on the left: it shows the row number, swaps to a
  checkbox on hover, with `N / total selected` top-right in the toolbar.
- **A Clay toolbar** on one line: the view name with a caret (`Dream 100 ▾`) on the left, then
  `Filter`, `Sort`, `Columns`, `Export` as light text buttons with line-icons.
- **Cells conditional-format plain:** the ICP as a small colored chip by tier (green 85 and up,
  amber 70 to 84, orange under 70); email a status dot plus its provider mark; a stale
  `verified Nd ago` (over 30d) turns amber.
- Theme-aware (light/dark, `prefers-color-scheme` plus `data-theme`).

## Functionality (all client-side, self-contained)

1. **Enrichment waterfall as default columns, with the real provider logos.** One column per
   email provider in the locked trust order (Prospeo, Dropcontact, Apollo, Hunter, Findymail).
   Each header carries **that tool's real logo** (see Provider logos below), not a letter. Each
   cell shows **the email that provider returned plus its verification**: the chosen work email
   marked with a star, rejected candidates struck through in red (invalid) or amber (risky),
   misses a dash, providers not reached left blank. The same logo sits next to the source in the
   Work Email cell. Hover shows credits. This is the Clay waterfall made visible.
2. **Per-client views as bottom tabs** (like Clay's saved views). Generated from the data:
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

## Provider logos (embed them, the CSP blocks linking)

The waterfall columns and the Work Email source carry each tool's real logo. Because the
artifact cannot fetch external images, the marks must be inlined in the file:

- Prefer an SVG the user dropped in `references/logos/<provider>.svg` (crisp and exact).
- Otherwise fetch each provider's favicon (for example the Google favicon service for their
  domain), base64-encode it, and inline it as a `data:` URI. Favicons are the genuine marks and
  small (about 15KB for the full set of Prospeo, Dropcontact, Apollo, Hunter, Findymail, plus
  NeverBounce and ContactOut).
- Route every provider mark through one `brandChip(provider)` hook that prefers an embedded
  logo and falls back to a brand-colored monogram chip (a colored tile plus the initial in that
  tool's brand color) when no logo is available. A rebuild then degrades gracefully, and a
  single drop-in SVG upgrades a chip to a real logo.

Never use the Clay logo. These are the enrichment providers' own marks, and they read as
"this is a real enrichment stack" the moment someone opens the sheet.

## Build constraints (Artifact CSP)

One file, everything inlined. No external fonts, scripts, images, or fetch. Icons as inline SVG
data URIs or unicode. No doctype/html/head/body wrapper. Wide grid scrolls in its own
container; the page body never scrolls sideways. Keyboard focus plus `Escape` closes the drawer.

## To refresh with live data

Re-run the SQL, replace the embedded `DATA`, republish to the same artifact file path (keeps
the URL). Structure never changes; only the rows do.
