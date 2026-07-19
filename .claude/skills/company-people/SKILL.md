---
name: company-people
description: Give it a list of companies (LinkedIn company URLs or domains) and it finds the decision maker at each one, founder / co-founder / CEO / owner / GTM lead, with a verified email, and saves them into your lead store. It scrapes each company's LinkedIn People tab via Apify (HarvestAPI), filters to the right titles, pulls the email, verifies it with NeverBounce inside the skill, flags catch-all and risky, and writes the keepers to your store (your own Supabase, or Airtable/Sheets/CSV). This is the most reliable people layer (LinkedIn has nearly every founder), so it is the catch-all that fills the gaps the databases miss, and it works standalone on any company list. Run it after lookalike-builder, which hands you the companies.
---

# Company to decision-maker (LinkedIn people layer)

## What it does

You give it **companies** (LinkedIn company URLs, or domains) and it returns the **decision
maker at each** with a **verified email**, saved into your **lead store**. LinkedIn is the
source of truth, nearly every agency founder is on it, so this is the **most reliable way to
get the person**, and the natural catch-all for companies the data vendors could not find a
person for. Run it **after `lookalike-builder`**, which discovers the companies and hands
them here.

```
companies (LinkedIn URLs)  ->  Apify HarvestAPI scrape the /people/ tab
                           ->  filter Founder/Co-Founder/CEO/Owner/GTM/Head of Growth
                           ->  email from the scrape
                           ->  NeverBounce verify (inside this skill)
                           ->  route: valid keep, catch-all flag, invalid drop
                           ->  your lead store
```

## How to invoke

`/company-people`, paste or point it at a list of company LinkedIn URLs (or domains), or
hand it the companies from `lookalike-builder`.

## Make it yours (first run)

Read `context/index.md`, then `context/icp.md` for the buyer. Confirm the decision-maker titles with the user once, in their words (Founder and CEO, or Head of Growth, or something specific to their motion), since that title list is exactly what the scrape filters on. Write the confirmed titles into `context/icp.md` so the next run and the other find-skills use the same buyer.

## First-run setup (run once as a short interview)

**1. Apify (required), the scrape.** Check `APIFY_TOKEN`. The actor is
`harvestapi/linkedin-company-employees` ("No Cookies", returns name, title, LinkedIn URL,
and an email). It needs a one-time permission approval in the Apify console the first time
(full-access actor). If a run returns `full-permission-actor-not-approved`, send the user
the approval URL it gives.

**2. NeverBounce (required), the verify.** Check `NEVERBOUNCE_API_KEY`. The skill verifies
every scraped email itself, so the list lands already graded.

**3. Your lead store (required), where the list lands.** This is your own database, not a
vendor lock-in. Read `connections.md` for the configured store:
- **Supabase (recommended):** the Supabase MCP is connected and `supabase/schema.sql` has
  been run (see `supabase/README.md`). You write leads with `execute_sql`.
- **Airtable or Google Sheets:** append rows to the configured table.
- **Nothing set up yet:** offer to set up the Supabase store (it is one MCP add plus one
  schema run), or fall back to writing a CSV into `leads/`.

**4. Optional, Prospeo (`PROSPEO_API_KEY`)** for the fallback layer (find a fresh email off
the LinkedIn URL when NeverBounce says the scraped email is *invalid*). Off by default; see
Phase 4.

---

## Phase 1, the company list and the title filter

Take the companies. Preferred input is **LinkedIn company URLs**
(`https://www.linkedin.com/company/<slug>`), `lookalike-builder` already returns one per
company. If you only have domains, resolve each to its LinkedIn company URL first.

Default **decision-maker titles** (the `jobTitles` filter, applied at scrape time):

```
Founder, Co-Founder, CEO, Owner, Managing Partner, Managing Director,
GTM Engineer, Head of Growth
```

Keep it tight. For a 3 to 20 person agency the People tab is small, so this filter returns
essentially just the founder and leadership. Tune only if the user names a different buyer.

## Phase 2, preview the cost, then WAIT (the gate)

This skill spends real money (Apify compute plus NeverBounce). **Always show the estimate
and wait for an explicit yes before scraping.**

```
N companies -> about N decision-makers (about 1 founder each on a small agency).
Cost: scrape about $0.012/profile (HarvestAPI Full+email) + verify about $0.004/email
      -> roughly $<N * 0.016> for N companies.
Proceed?
```

Never scrape before the user confirms.

## Phase 3, scrape the people (Apify HarvestAPI)

Batch the company URLs (the actor accepts many in `companies`). Run sync and read the
dataset:

```bash
curl -s --max-time 600 -X POST \
  "https://api.apify.com/v2/acts/harvestapi~linkedin-company-employees/run-sync-get-dataset-items?token=$APIFY_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{ "companies": ["https://www.linkedin.com/company/example", "..."],
        "jobTitles": ["Founder","Co-Founder","CEO","Owner","Managing Partner","GTM Engineer","Head of Growth"],
        "maxItems": 500,
        "profileScraperMode": "Full + email search ($12 per 1k)" }'
```

Per person read: `firstName` + `lastName`, `linkedinUrl`, `headline` or `currentPosition`
(title), `companyWebsites`, and **`emails[0].email`** (plus the scrape's own `status` /
`catchAllDomain`, a hint, not the verdict). The JSON can contain raw control characters,
parse leniently (`strict=False`). If a run returns the permission error, surface the
approval URL and stop.

## Phase 4, the email waterfall (verify each, continue on fail)

This is the Clay rule and the difference between a lead list and a trustworthy one. Do not
just keep the scraped email. Resolve the work email:

1. Call email providers in the **locked trust order**: HarvestAPI (from the scrape), then
   Prospeo, Dropcontact, Apollo, Hunter, Findymail. Verifier: NeverBounce (or ZeroBounce),
   with skip-catch-all on. HarvestAPI already returned one candidate with the scrape; the rest
   are fallbacks, tried only if the ones before fail. This order is the default the render and
   the spec assume, keep it unless the user changes it.
2. **Verify each returned address immediately** with NeverBounce:
   ```bash
   curl -s "https://api.neverbounce.com/v4/single/check?key=$NEVERBOUNCE_API_KEY&email=jane@acme.com&address_info=1"
   # -> result: valid | invalid | disposable | catchall | unknown
   ```
3. **Stop at the first that verifies deliverable (`valid`)**, that is the work email. `catchall`
   and `unknown` are risky candidates, keep one but keep trying if another provider is available.
   `invalid` / `disposable`: **discard and continue** to the next provider.
4. You only pay for the providers that actually run.

So the work email is the first candidate, in trust order, that passes verification, not simply
"the one we found". Every candidate (verified, risky, or discarded) gets recorded in Phase 5.

## Phase 5, save to your lead database (company, person, candidates, waterfall log)

Per decision-maker, four writes. **Supabase (recommended)** via the MCP:

```sql
-- 1. Upsert the company (firmographics live once, shared by everyone there). Get its id.
insert into companies (name, domain, linkedin_url, industry, employee_count, enriched_at, enriched_by)
values ('Acme', 'acme.com', 'https://www.linkedin.com/company/acme', 'agency', 8, now(), 'company_people')
on conflict (domain) do update set enriched_at = now()
returning id;   -- <COMPANY_ID>

-- 2. Create or reuse the list, then insert the person. leads.email mirrors the CHOSEN candidate.
insert into lead_lists (name, source) values ('LinkedIn, agency founders', 'company_people') returning id;

insert into leads (lead_list_id, company_id, name, title, seniority, linkedin_url,
                   email, email_status, email_source, email_verified_by, email_verified_at,
                   last_verified_at, credits_spent, status, source, client)
values ('<LIST_ID>', '<COMPANY_ID>', 'Jane Doe', 'Founder', 'founder',
        'https://www.linkedin.com/in/janedoe',
        'jane@acme.com', 'verified', 'harvestapi', 'neverbounce', now(), now(), 0.016,
        'new', 'company_people', null)
on conflict (lead_list_id, lower(email)) do update
  set email_status = excluded.email_status, email_source = excluded.email_source,
      email_verified_by = excluded.email_verified_by, last_verified_at = now(), title = excluded.title
returning id;   -- <LEAD_ID>

-- 3. Write EVERY candidate email to lead_emails, mark the chosen one primary.
insert into lead_emails (lead_id, email, kind, provider, verification, is_primary) values
  ('<LEAD_ID>', 'jane@acme.com', 'work', 'harvestapi', 'verified', true),   -- the chosen one
  ('<LEAD_ID>', 'j.doe@acme.io', 'work', 'apollo',     'invalid',  false)   -- a discarded candidate
on conflict (lead_id, lower(email)) do nothing;

-- 4. Log the waterfall: one row per provider AND verifier call, with its cost.
insert into enrichment_events (lead_id, company_id, field, provider, status, value_found, credits, ran_at) values
  ('<LEAD_ID>', '<COMPANY_ID>', 'work_email', 'harvestapi',  'hit',      'jane@acme.com', 0.012, now()),
  ('<LEAD_ID>', '<COMPANY_ID>', 'work_email', 'neverbounce', 'verified', 'jane@acme.com', 0.004, now());
```

**Why `lead_emails` matters.** A provider can return an address that fails verification, so a
person can have several candidates and one chosen. Storing them all, not just the winner, is
what lets the spreadsheet show the provider-by-provider waterfall (chosen email starred,
rejected ones struck through) and is the audit trail behind the score. `leads.email` is a
convenience mirror of the primary `lead_emails` row for fast reads and the view.

Firmographics (`industry`, `employee_count`) live on the **company**, never per person. If
`lookalike-builder` already inserted the company, step 1 just updates it and returns the same
id. For a client run, set the lead's `client` to the slug. For **Airtable / Sheets / CSV**,
append company + person + a provenance column as a flat row.

Then point the user at `signal-scan` (buying signals + the ICP score) and `content-scan`.

## Hard rules, never break these

- **Confirm the cost before scraping.** Phase 2 shows the estimate and waits.
- **Verify inside the skill (NeverBounce).** Grade every email here so the list lands clean.
- **Catch-all = keep and flag, never "fix" with Prospeo.** No tool verifies a catch-all domain; Prospeo helps only on `invalid`.
- **Never invent an email.** Drop `invalid` and `disposable`; flag `risky`.
- **Stamp the lead source** (`company_people`) so reply rates compare across sources.
- **The store is yours.** Write to the user's own database, never a vendor the user does not control.

## How this fits the bigger picture

The find-skills split by source, each its strength:
- `lookalike-builder` discovers the **lookalike companies** (irreplaceable), and hands them here.
- **`company-people` (this)** is the LinkedIn people layer: the most reliable way to get the founder at a known company, and the catch-all that fills the gaps the databases miss.
- `signal-scan` then enriches each lead with buying signals and the ICP score; `content-scan` adds LinkedIn intent on the qualified ones.

## Cost

Apify HarvestAPI: **Short $4/1k profiles** (person only) or **Full+email $12/1k** (person +
email, used here so emails are bundled). NeverBounce verify about **$0.003 to $0.008/email**.
So about **$0.016 per decision-maker**, all in. Prospeo fallback (optional) about $0.02 only
on the `invalid` slice.

## FAQ

**Why LinkedIn instead of a database?** LinkedIn has nearly every founder; the databases miss
many. This is the catch-all that gets the people they do not have.

**Do I pay for emails separately?** No, the scrape's Full+email mode bundles the email, and
NeverBounce just verifies it (cheap).
