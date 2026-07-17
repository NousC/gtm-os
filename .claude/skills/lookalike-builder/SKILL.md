---
name: lookalike-builder
description: Paste up to 5 companies you'd love to work with (or describe the niche) and AI-Ark's similarity model finds the lookalike companies. The core job is building the company table, discover the lookalikes, narrow with include/exclude keywords and firmographics, ICP-score, and save the companies into your own lead store. The whole search and count is free to preview. It then hands the company list to company-people (LinkedIn scrape, about 90% coverage on small agencies) for the decision makers and verified emails. Rule of thumb: lookalike-builder discovers the COMPANIES, company-people turns them into DECISION MAKERS. Use AI-Ark's own people search only on bigger, well-indexed companies (50+) where a title-filtered database query beats scraping a large People tab.
---

# Lookalike lead builder (AI-Ark)

## What it does, and what it is for

You paste **up to 5 companies you'd love to work with**, or just describe the niche, and
AI-Ark's similarity model returns the **lookalike companies**. The **core deliverable is the
company table**: the similar companies, narrowed by include/exclude keywords and
firmographics, ICP-scored, saved into your own lead store.

That company discovery is the **irreplaceable** thing AI-Ark does, one API does lookalike
plus include plus exclude. It is the only job we reach for this skill to do by default.

> **The split.** AI-Ark has two engines and they are not equal. **Company lookalike search
> is excellent, always use it.** Its **people index is thin for small agencies** (about 37%
> of 3 to 20 person companies had any indexed decision-maker on a real run). So the
> recommended pipeline is **lookalike-builder for the COMPANIES, then `company-people`
> (LinkedIn scrape) for the DECISION MAKERS and emails** (about 90% coverage). Use AI-Ark's
> own people search only on bigger, well-indexed companies (50+).

```
[0] EXCLUDE-OWN  build an exclude list from the domains already in your store  -> no re-finds
[1] LOOKALIKE    Company Search lookalikeDomains:[5 seeds]  -> similar companies
[2] NARROW       + filters: size, location, INCLUDE keywords -> tighter set
[3] EXCLUDE      + exclude keywords + the exclude-own list   -> the noise removed
[4] PREVIEW      count + sample, NO emails, NO spend         -> you approve here
[5] SAVE         ICP-score companies -> your lead store (the company table)  <- DEFAULT STOP
                 then hand the company list to /company-people for the people layer
[6] PEOPLE       (optional) AI-Ark People Search for 50+ companies -> founders + emails
```

## How to invoke

`/lookalike-builder`, then paste seeds, e.g. "like anna-agency.com, bravo-collective.com,
growthlab.io, founders, 1 to 10 people, US", or describe the niche and it builds the spec.

## Make it yours (first run)

Before the first search, fit the target to the user's business. Read `context/index.md`, then `context/icp.md`. Then ask only what the wiki does not already say:

- Three to five dream companies they would love more of. These are the seeds.
- Their team-size band, and the "looks similar but is not us" shops to exclude (design, SEO, PR, recruiting, whatever is noise for them).

Write the seeds and the exclusions into `context/icp.md`, so the next run starts from them and every find-skill shares the same target.

## First-run setup (run once as a short interview)

**1. AI-Ark (required), the search.** Check for `AIARK_API_KEY`. Missing: "I find the
lookalike companies through AI-Ark. `export AIARK_API_KEY=...` (ai-ark.com, Settings, API).
Auth is the `X-TOKEN` header. Usage-based, credits roll over up to 2x: $49/mo = 5,000
credits, $79/mo = 15,000 credits. The match COUNT is free, but pulling records costs credits,
see Cost."

**2. Your lead store (required), where the list lands and what you dedup against.** Your own
database, not a vendor lock-in. Read `connections.md`:
- **Supabase (recommended):** the Supabase MCP is connected and `supabase/schema.sql` has
  been run (see `supabase/README.md`). You dedup and insert with `execute_sql`.
- **Airtable / Sheets / CSV:** the configured table, or a CSV in `leads/`.
- **Nothing yet:** offer to set up the Supabase store (one MCP add plus one schema run).

AI-Ark returns BounceBan-verified emails on the optional people path, so no separate verify
tool is needed there.

## Phase 0, exclude what you already have

Every company already in your store is one you should not re-find or re-pay for. Pull the
domains you already own and feed them to AI-Ark as an exclude list.

**Supabase:** `select distinct domain from leads where domain is not null;` (via the MCP
`execute_sql`). Collect them into one deduped set, and also gather the domain from each
lead's email. Pass this set to AI-Ark's exclude in Phase 3. Tell the user what you excluded:
"Excluded the N companies already in your store."

## Phase 1, build the targeting spec from the seeds

Turn whatever the user gives into a structured AI-Ark spec. **Do not overcomplicate the
keywords.** The lookalike is the engine; a short, sharp **exclude** list plus a tight **team
size** is what separates the real ICP from the look-alikes that share its vocabulary (a real
outbound agency vs a web-design or SEO shop that also says "marketing"). Load the ICP lens
from the context wiki first: read `context/index.md`, then `context/icp.md`, to know the
buyer, the size band, and the disqualifiers.

```
Seeds (lookalikeDomains, up to 5): the companies the user pasted
Company filters: staff range (enforce strictly, see note), location, INCLUDE keywords
Exclude keywords: the "looks similar but is not the ICP" set (design, SEO, PR, recruiting...)
```

> Two AI-Ark behaviours to respect: Company Search `totalElements` **caps at 10000** (a
> ranked similarity stream, not an exact total), and **firmographic filters are soft under
> lookalike** (size 1 to 10 still returns some 11 to 50), so enforce size strictly as a
> post-filter on `summary.staff.range`.

## Phase 2, preview the count and a rough cost, then WAIT

Run the free count first. Show the estimate and wait for a yes before pulling records (that
is what costs credits).

```
About <N> lookalike companies match after your excludes.
Pulling and storing them costs about <N * 0.5> credits (browse/store 0.5 each).
Emails, only on the optional people path, cost extra. Proceed?
```

Never pull the records before the user confirms. Pull the **top-N ranked lookalikes** (best
matches first), do not page the whole tail.

## Phase 3, AI-Ark company search

Call AI-Ark Company Search with `lookalikeDomains`, the include keywords, and the exclude
list (Phase 0 plus Phase 1). Read each result's domain, `summary.staff.range`, industry,
location, and its LinkedIn company URL (`link.linkedin`, this is what `company-people` needs).
Post-filter size strictly. Keep the ranked order.

## Phase 4, ICP-score the companies

Score each company against the ICP lens (Phase 1). If Nous is connected, `record` the company
firmographics and let the resolved record compute the score, then read it back; otherwise
score heuristically from the lens (size, keywords, disqualifiers). This is the filter that
decides which companies are worth handing to `company-people`.

## Phase 5, save the company table to your lead store (DEFAULT STOP)

Insert the companies as leads (person fields blank for now, `company-people` fills them).
**Supabase** via the MCP:

```sql
insert into lead_lists (name, source) values ('Lookalikes of <seed>', 'lookalike') returning id;

insert into leads (lead_list_id, company, domain, linkedin_url, industry,
                   employee_count, icp_score, icp_reason, status, source)
values ('<LIST_ID>', 'Acme', 'acme.com', 'https://www.linkedin.com/company/acme',
        'agency', 8, 82, 'matches size + outbound keywords', 'new', 'lookalike')
on conflict (lead_list_id, lower(email)) do nothing;
```

(For a company-only row the `email` is null, so the unique-on-email conflict does not fire;
dedup on `domain` in your insert logic.) For **Airtable / Sheets / CSV**, append the same
fields.

Then **hand off**: "Company table saved, N companies, top-scored first. Run `/company-people`
on this list to get the founder and verified email at each." That is the default stop.

## Phase 6, optional, AI-Ark people and emails (50+ companies only)

For big, well-indexed companies, AI-Ark's own People Search plus email-finder can pull the
decision-maker and a BounceBan-verified email in one tool. Confirm the email spend first,
dedup against the store, then write the people into the same rows. For small agencies, skip
this and use `company-people` instead, its LinkedIn coverage is far higher.

## Hard rules

- **Preview free, spend on a yes.** The count is free; pulling records and emails costs. Always show the estimate and wait.
- **Company search is the job.** The lookalike discovery is the irreplaceable part. Default to stopping at the company table and handing off.
- **Enforce size strictly** as a post-filter, AI-Ark's size filter is soft under lookalike.
- **Exclude what you already own** (Phase 0), never re-pay for a company already in your store.
- **The store is yours.** Write to the user's own database, never a vendor they do not control.
- **Stamp the source** (`lookalike`) so reply rates compare across sources.

## Cost

AI-Ark credits: valid email 0.5, contact storage 0.5, lookalike browse/store 0.5, basic
company 0.1. A finished lead (kept contact plus verified email) is about 1 credit. Plans:
$49 = 5,000 credits, $79 = 15,000 credits, roll over up to 2x. Per-lead at the $79 tier about
$0.005. The catch: browsing lookalikes to find the keepers costs 0.1 to 0.5 each on top, so
pull the top-N ranked, do not page the tail.

## How this fits

`lookalike-builder` discovers the companies, `company-people` turns them into decision
makers, `signal-scan` enriches each with buying signals and the ICP score, `content-scan`
adds LinkedIn intent on the qualified ones. Every one writes to the same lead store.
