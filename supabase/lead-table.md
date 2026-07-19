# Rendering the lead database as an artifact

When the user asks to see their leads, render the database as a **spreadsheet**, a real
data grid, the way Clay shows a table. It must not look like a dashboard. No hero, no big
title, no KPI tiles, no charts, no cards wrapped around the table, no gradients. Just the
grid, dense and minimal, focused on the data. If it looks like a marketing page, it is
wrong. If it looks like a spreadsheet you could work in, it is right.

Load the `artifact-design` skill first for the general design bar, then follow this spec,
which overrides it toward the spreadsheet look. Publish with the Artifact tool.

## The data

Read the `lead_rows` view via the Supabase MCP (`execute_sql`), filtered to what the user
asked for (a list, a score floor, a client, a status). Example:

```sql
select * from lead_rows
where client is null or client = '<slug>'   -- scope for agencies
order by icp_score desc nulls last
limit 1000;
```

Embed the returned rows as a JSON array inside the page. An artifact cannot fetch live (the
CSP blocks it), so this is a point-in-time snapshot. Say so, and regenerate to refresh.

## The layout

A single full-width table. Nothing above it but a thin toolbar.

- **Toolbar (one line, minimal).** Left: the list name and the exact row count, e.g.
  `Dream 1000  ·  213 rows`. Right: a filter input (`Filter…`) and the current sort. That is
  the whole chrome. No logo, no buttons row, no tabs.
- **Header row.** Sticky on vertical scroll. Small uppercase labels, a thin bottom border, a
  tiny leading icon per column is fine (a monogram, not emoji). Click a header to sort by it.
- **Columns, in this order** (Clay reads left to right, identity then signal then score):

  | Col | Content | Notes |
  |---|---|---|
  | `#` | row number | sticky left, muted |
  | Company | company name + a small monogram/favicon square | sticky left |
  | Name | person name | |
  | Title | title, with seniority muted under or beside it | |
  | Email | the address + a status dot | dot: green verified, amber risky/catchall, red invalid. On hover or a caption, show `email_source` (the provider that found it). This is the provenance, do not hide it entirely. |
  | Score | the ICP score, as a colored chip | see below |
  | Employees | `employee_count` (or range) | right-aligned, tabular-nums |
  | Industry | `industry` | |
  | Signals | a compact cell: the count, or the top signal label | click the row to expand the full detail |
  | Status | a small muted pill | new / qualified / queued / sent / replied / dropped |
  | Tags | small chips | |
  | Verified | `last_verified_at` as a relative age (`3d`) | muted, right-aligned |

- **The score chip** is the visual anchor, like Clay's colored score. A small rounded chip
  showing the number, colored by band: 80+ strong (green), 60 to 79 good (teal or blue), 40
  to 59 weak (amber), under 40 low (gray). Use the palette from `artifact-design`, do not
  invent loud colors. The chip earns its place; nothing else should compete with it.
- **Sticky left** the `#` and Company columns so horizontal scroll keeps context.
- **Row detail (the "see how it works" view).** Clicking a row expands an inline panel or a
  right drawer showing the full picture for that lead: the company signals and the person's
  intent (from `person_signals` / `company_signals`), the `icp_reason`, the email and its
  `email_source` and verification, and any notes. This is where the user sees what the AI
  found and why the score is what it is. Keep it a clean two-column key/value read, not a card.

## The style (the anti-dashboard rules)

- Dense rows, small cell padding (roughly 6px vertical, 10px horizontal), 1px hairline
  borders or a single bottom border per row. A subtle zebra or a hover highlight, not both.
- A system font for labels; **tabular-nums** for every number (score, employees, dates) so
  columns line up.
- Light and dark, driven by `prefers-color-scheme` plus the `data-theme` override, per
  `artifact-design`. Neutral grays, one accent, color only on the score chip and the email
  status dot.
- The table scrolls horizontally inside its own `overflow-x: auto` container. The page body
  must never scroll sideways.
- No rounded card around the grid, no drop shadow, no section headings, no summary stats
  above it. If you feel the urge to add a "Total leads" tile or a pie chart, do not.

## Interactions (plain, client-side)

- **Sort** by clicking any header, toggling asc/desc, default score desc.
- **Filter** with the toolbar input, matching name, company, email, title, tag, live.
- **Row expand** for the detail panel above.
- Everything is inline JS on the embedded snapshot. No network.

## The one line to keep in mind

It is a spreadsheet of leads that happens to be scored and enriched, not a dashboard about
leads. Present the data, get out of the way.
