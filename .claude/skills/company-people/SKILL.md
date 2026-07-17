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

## Phase 4, verify each email with NeverBounce (inside the skill), then route

Do NOT trust the scrape's self-graded status. Verify here so the list lands graded. Call
NeverBounce single-check per email:

```bash
curl -s "https://api.neverbounce.com/v4/single/check?key=$NEVERBOUNCE_API_KEY&email=jane@acme.com&address_info=1"
# -> { "status":"success", "result":"valid|invalid|disposable|catchall|unknown", "flags":[...] }
```

Route by `result`:
- **`valid`** -> keep, `email_status = verified`.
- **`catchall`** -> keep, `email_status = risky` (a catch-all domain cannot be confirmed by any tool, this is the domain's nature, not a bad address; send at your discretion).
- **`unknown`** -> keep, `email_status = risky`.
- **`invalid` / `disposable`** -> drop the email. (Fallback, optional, off by default: if `PROSPEO_API_KEY` is set, re-find off the `linkedinUrl` via Prospeo, then re-verify. This is the only case Prospeo helps, never for catch-all.)

## Phase 5, save to your lead store

Insert the keepers with their verified status. **Supabase (recommended)** via the Supabase
MCP: create or reuse the list, then insert one row per decision-maker.

```sql
-- create or reuse the list
insert into lead_lists (name, source) values ('LinkedIn, agency founders', 'company_people')
returning id;

-- insert one row per decision-maker (run per lead, or batch the values)
insert into leads (lead_list_id, name, email, email_status, company, domain,
                   linkedin_url, title, industry, employee_count, status, source)
values ('<LIST_ID>', 'Jane Doe', 'jane@acme.com', 'verified', 'Acme', 'acme.com',
        'https://www.linkedin.com/in/janedoe', 'Founder', 'agency', 8, 'new', 'company_people')
on conflict (lead_list_id, lower(email)) do update
  set email_status = excluded.email_status, title = excluded.title,
      linkedin_url = excluded.linkedin_url;
```

If `lookalike-builder` already inserted the company, update that row with the person instead
of inserting a new one (match on `domain`). Map: `name` from firstName+lastName,
`linkedin_url` from `linkedinUrl`, `company` from the input company, `email` from the
verified address, `email_status` from the NeverBounce verdict, `title` from
headline/position.

**Pass firmographics through**, `industry` and `employee_count`. When `lookalike-builder`
hands you the gap companies it already knows each one's industry and size, carry them onto
every person you save. Standalone, set `industry` from the company and `employee_count` from
the scrape's company size if present. These are what the ICP score reads, drop them and the
lead cannot be scored.

For **Airtable / Sheets / CSV**, append the same fields as a row. For **Nous (optional)**,
you can also `record` the person and company so the resolved record and your store agree,
but the store is the lead list.

Then point the user at `signal-scan` (which enriches these same rows with buying signals and
the ICP score) and `content-scan` after that.

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
