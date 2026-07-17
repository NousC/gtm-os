---
name: signal-scan
description: The first enrichment pass. Scan an account (or a whole lead list) for buying signals from the company website plus what the resolved record already knows, rank them, record a structured signal block onto the account so it powers ICP scoring, and save a comprehensive signal brief as a note, each signal carrying the named copy-variables (raise_size, founder_handle, buyer_post_url) that an outreach skill later injects. Signals are the features the ICP model scores on, and the brief is the copy-fuel outreach reads. Use it when the user says "scan my list for signals", "find buying signals on these accounts", "research and prioritize this list", "what's going on at these companies", "enrich my leads with signals", or before scoring or working a list. It does one thing and hands off: it does NOT scrape LinkedIn posts (that is content-scan, run later only on ICP-qualified leads) and does NOT write outreach. For a single 1:1 pre-meeting brief, use a meeting-brief instead.
---

# Signal scan

## One job

Scan an account (or every account in a lead list) for **buying signals**, concrete and
current facts about the situation a company is in, rank them, and **record a signal block
onto the account**. That is the whole job.

Why it exists: signals are the **features the ICP model scores on**. You cannot score fit
well without them. signal-scan is the first enrichment pass that gives the record something
real to score. Everything downstream (the deeper post-based Intent layer, the outreach
copy) is a **different skill** that runs after this.

The boundary, on purpose:
- **This skill:** signals from the website plus what the record knows, recorded on the account.
- **content-scan (separate, later):** LinkedIn posts into deeper Intent, run only on leads that score above the ICP threshold (about 70). Not here.
- **Your outreach skill (later):** writes the message. Not here. See `EXPANSIONS.md`.

One source of truth: **the resolved record**. The signal block is written onto the account,
not a separate local file. The full readout is shown in chat at runtime; the record that
persists is the concise one on the account.

## How to invoke

`/signal-scan`, or "scan my GTM founders list for signals", "what's going on at the accounts
in my engagers list".

Resolve from the prompt:
- **Target:** one account or domain, or a lead-list name or id (ask and list the lists if unclear).
- **Scope:** whole list, or a cap (top 100). Default: whole list.

## Make it yours (first run)

The first time you run this, take a minute to fit it to the user's business, so it never scans against a generic profile. Read `context/index.md`, then `context/icp.md` and `context/positioning.md`. Then ask the user only what those files do not already answer, in a short back and forth, not a form:

- Which of the six signal classes matter most for your offer? A hiring surge, a funding round, a specific tool in their stack?
- What is a hard disqualifier a good-looking company might still fail on?

Write the answers back into `context/icp.md` (the buyer, the disqualifiers), so the whole OS gets sharper and the user is asked once, not every run. Skip anything the wiki already answers. This is the personalization that makes the score theirs.

## First-run setup

Try the resolved record's `get_context` tool.
- Connected, go.
- Not connected: the scan still runs on the website and the readout, but nothing persists
  and nothing gets scored. Say that plainly and offer to wire the record in (see
  `connections.md`): `claude mcp add nous -e NOUS_API_KEY=<pk_...> -- npx -y @opennous/mcp`
  (key at opennous.cloud, Settings, API keys). Confirm `get_context` works, then re-run so
  the signals land and score.

No Apify, no paid API. Website signals use plain `WebFetch`, free.

## The six signal classes

Every signal belongs to one class. Score each **1 to 10** (a heuristic prior; the weekly
review later replaces it with the learned weight).

| Class | What it captures | Where (website + record) |
|---|---|---|
| **Stack** | tools they run, competitor usage, duct-taped processes | integrations, footer, pricing, known facts |
| **Hiring** | roles posted, especially ones signalling strain or that your buyer owns | /careers, /jobs |
| **Momentum** | funding, expansion, new markets, headcount growth | homepage news, /about, known facts |
| **Friction** | public complaints, broken-process tells | reviews, support pages, blog |
| **Intent** | site or blog language showing they are working the problem | /blog, news (deep post-based Intent is content-scan, later) |
| **Domain** | vertical or marketplace tells unique to their niche | homepage, known facts |

Strength guide: 8 to 10 behavioural and exclusive (a direct competitor with friction,
hiring the role you replace); 5 to 7 adjacent tool or growth pattern; 3 to 4 size or stage
suggests it; 1 to 2 basic ICP fit only.

## The process

Per account, in order. Note thin sources, never fabricate a signal.

### 1. Load the offer and ICP lens from the context wiki

The ICP lives in the user's own wiki, not a web form. Read `context/index.md` first, then
**read `context/icp.md`** (the buyer and the offer) and `context/positioning.md` (what you
sell and why). That prose is the lens: which of the six classes actually matter for this
offer. A hiring signal is noise unless the offer says that strain is a problem you solve.
Judge every signal against *this* ICP.

If the record is connected and holds a learned scoring model, refresh it: `get_icp_model`
returns the model, `get_icp` re-syncs the file into the record if it changed, and
`get_gtm_profile` fills any product or competitor gaps the file does not cover. If there is
no `context/icp.md` yet, point the user at `/onboard` and offer to work from
`context/positioning.md` in the meantime.

### 2. Pull what the record already knows

`get_context` (intent `account_review`) returns known facts, ICP fit (0 to 100 plus why),
and company detail. Do not re-derive what the record already has, build on it.

> **Resolve each lead by its email or LinkedIn URL, never the display name.** Name lookup
> is unreliable and 404s (`entity_not_found`). Lead lists carry the email or `linkedin_url`,
> use those as `focus` (or the entity UUID). Same for `record` and `record_signal`.

### 3. Scan the website (free)

Resolve the domain. Use the built-in **`WebFetch`** tool on the homepage plus `/about`,
`/careers` (or `/jobs`), `/product`, `/pricing`, `/blog`, and the footer or integrations
where they exist. Read them for the six classes.

> `WebFetch` is Claude Code's built-in fetcher (free, no API key). If a JS-heavy site
> returns little, say the source is thin. Optional upgrade: if `FIRECRAWL_API_KEY` is set,
> use Firecrawl for JS-rendered sites, richer but paid. Default to free `WebFetch`.

### 3b. Record the company description and keywords (powers the keyword scoring rules)

The ICP score reads two plain company facts firmographics do not give it: **`description`**
(what the company does, one paragraph) and **`keywords`** (the GTM terms on their site).
These drive the keyword fit rules ("outbound agency", "cold email", "RevOps") and the
keyword disqualifiers, so without them most of the score cannot fire. From the site you
just read, if the record is connected, `record` both on the **company**:

```
record(focus: <domain>, observations: [
  { kind: "state", property: "description",
    value: "<1 paragraph, plain English: what they do, who for, how>",
    source: "signal-scan" },
  { kind: "state", property: "keywords",
    value: ["outbound agency","cold email","clay","ai sdr","lead generation"],
    source: "signal-scan" }
])
```

Keep `keywords` to the **5 to 12 concrete GTM terms actually on the site**, in the words a
buyer would use. No fluff. If the site is too thin to describe them, say so and skip, never
invent keywords.

### 4. Identify and rank signals

For each signal capture: **detected** (specific, factual), **implies** (their day-to-day
reality), **score** (1 to 10 per the strength guide above), **class**, **approach**
(pain-led, value-led, or fallback), **angle** (one line), and the **key data points for
copy** (below). Rank most exclusive and highest-intent first, pick the **anchor** (the
strongest). Always include a **fallback** for when no strong signal lands.

**Key data points for copy, the most important output.** A signal is not just a reason to
reach out, it is structured copy-fuel. For every signal, extract the **named variables** the
email will inject, the exact strings, not vague prose:

```
raise_size: "$140M Series C"          founder_handle: "Alex Jekowsky, Co-founder & CEO"
raise_date: "March 26, 2026"          founder_ai_thesis_quote: "horizontal AI hit a wall"
lead_investor: "Sumeru Equity"        buyer_post_url: "https://linkedin.com/posts/..."
expansion_verticals: "dry cleaners"   hiring_role: "VP Marketing"
```

These are what an outreach skill NAMES in the copy. **Every variable and every signal's
`detected` must be a specific named fact, never an abstraction.** The bar:
- funding to "$140M Series C, March 2026, Sumeru lead", not "recently funded"
- stack to "Clay + Smartlead + Apify, Smartlead Certified Partner", not "modern tooling"
- proof to "20+ meetings in 90 days", not "has case studies"
- verticals to "dry cleaners, route operators, tailors, cobblers", not "several verticals"
- hiring to "3 SDR roles posted in 30 days", not "they are growing"

If a field comes out vague, the source was too thin, dig further (another page, a web
search, the careers or about page), do not record fluff. The outreach skill NAMES these
observationally ("saw you closed a $140M Series C"), it never quotes a person's literal
words back at them. Capture the facts so the copy can name them.

### 5. Record the signals onto the COMPANY (not the person)

These six classes are **company facts**: stack, hiring, momentum, friction, and domain are
shared by everyone at the company. You will reach five people at one agency (Founder, Head
of Growth, Marketing VP), and the company signal is the same for all of them, so it belongs
on the **company entity**, not duplicated per person. The person's unique signal (their
voice and intent) comes later from `content-scan` and lands on the person. The person then
**inherits** the company signals automatically.

Use the **`record_signal`** tool. One call per signal, the **strongest one per class**:
- `focus`: the company **domain** (e.g. `acme.com`), so it resolves to the company entity shared by all its people. Not a person email.
- `signal_class`: stack, hiring, momentum, friction, or domain (intent comes from content-scan, on the person, do not write intent here).
  - **Two axes:** `hiring` and `momentum` are company **intent**, they feed the intent score (which decays) and are inherited by every person. `domain` and `stack` are company **fit**, they feed the durable ICP score. `friction` is copy fuel.
  - **Fold funding, product launch, news, and expansion into `momentum`**, capturing the named copy-variables (`raise_size:"$5M Series A"`, `launch:"..."`) so the copy can name them.
- `detected`: the specific, factual finding.
- `implies`: their day-to-day reality (optional).
- `score`: 0 to 10.
- `approach`: pain_led, value_led, or fallback (optional).
- `angle`: one-line outreach angle (optional).
- `variables`: the key data points for copy (in the brief).

This writes a structured `signal.<class>` claim on the company that (1) shows under the
company's Signals tab, (2) is inherited by every person at that company, and (3) feeds the
ICP score as a feature.

### 5b. Save the comprehensive signal brief as a note (the copy fuel)

The structured signals (5) feed *scoring*; the **brief** feeds the *writer*. After recording
the signals, save one comprehensive markdown brief with **`save_note`** on the same account.
This is the single document an outreach skill reads, so it must carry the named copy-variables,
not just prose, and it must follow this **exact structure** every time so every brief is
consistent. Title it `<Company> - Company Signals`.

```markdown
# Signal scan, <Company>

> <1-2 sentences: what they do, current situation, the most interesting finding>

Domain: <domain>
ICP fit: <score>/100
Signals: <n> (strongest first)

---

## Signal 1: <name>, Score X/10, <class>
Detected: <specific, factual, dated finding>
Situation it implies: <their Monday-morning reality>
Recommended approach: Pain-led | Value-led | Fallback
Campaign angle: <one sentence, the core message this signal enables>
Key data points for copy:
- <variable_name>: "<exact value>"

## Signal 2, 3 (same structure, strongest first)

## Fallback, Score X/10
Situation assumption: <most common pain for this profile when no strong signal lands>
Campaign angle: <one sentence>
Key data points for copy:
- <variable_name>: "<exact value>"
```

The **Key data points for copy** are the heart, named variables with exact values. The
structured `signal.*` records stay the source of truth for scoring; this note is the source
of truth for writing.

### 5c. Write the score and signals to your lead store

If the leads live in your own lead store (Supabase, see `supabase/README.md` and
`connections.md`), the store is the copy you work day to day, so write the results there too:
set the `icp_score`, put the six signal classes into the `signals` jsonb, and put the brief
into `signal_brief`. Via the Supabase MCP:

```sql
update leads
set icp_score = <0..100>,
    icp_reason = '<one line, why>',
    signals = signals || '{"stack":{...},"hiring":{...},"momentum":{...},"friction":{...},"domain":{...}}'::jsonb,
    signal_brief = '<the markdown brief from 5b>',
    status = case when <score> >= 70 then 'qualified' else status end
where lower(domain) = lower('<domain>');   -- or match on lower(email) for a specific person
```

If Nous is connected it computes the score from the `signal.*` features and you push that
same number into `leads.icp_score`, so the score in your own database matches the record's.
If there is no store configured yet, skip this step and note that setting one up (Supabase is
one MCP add plus one schema run) gives the signals a home you own.

### 6. Show the readout (chat only, not saved to a file)

Print the structured scan so the operator sees it now:

```
# Signal scan, <Company>   ICP fit: <score>/100
> <1-2 sentences: what they do, their situation, the most interesting find>

Signal 1: <name>  (Score X/10, <class>)
  Detected:   <factual finding>
  Implies:    <their Monday-morning reality>
  Approach:   Pain-led | Value-led | Fallback
  Angle:      <one sentence the signal enables>
  Copy vars:  raise_size="$140M" · founder_handle="..." · buyer_post_url="..."

Signal 2, 3
Fallback (Score X/10)
```

When scanning a list, also print a one-row-per-account table (account, ICP fit, anchor
signal, score) and note which cleared the ICP threshold, those are the ones to send to
content-scan next.

## Running at scale, scout once, fan out, assemble

For a single account, run steps 1 to 6 inline. For a **list (about 10 or more accounts)**,
fan out instead, accounts are independent and every write goes to the record per-entity, so
there is no shared local file and no collision.

1. **Scout once (you, the main agent).** Resolve the list and pull the accounts. Load the
   ICP lens a **single time** (step 1).
2. **Fan out, one sub-agent per account, in capped batches (about 8 to 10 at a time).**
   Paste the ICP lens in so each never re-fetches:
   > "Run signal-scan on this one account: `<email/domain>`. ICP lens: `<paste>`. Do steps
   > 2 to 5b: `get_context`, `WebFetch` the site, `record` the company `description` and
   > `keywords`, classify the six classes, for each extract the key data points for copy,
   > `record_signal` the strongest per class, `save_note` the comprehensive brief. Return
   > only the readout row: account, ICP fit, anchor signal, score."
   Use the `gtm-operator` sub-agent (or a general one). Cap concurrency at about 8 to 10.
3. **Assemble (you).** Collect the rows into the table and flag who cleared the ICP
   threshold (about 70), that is the hand-off list for content-scan.

For a **handful (5 or fewer)** the fan-out is not worth the overhead, run them inline.

## Hard rules

- **Be specific, not generic.** "They are growing" is not a signal. "Posted 3 supply-chain coordinator roles in the last 30 days" is.
- **Connect every signal to the offer.** It only matters if it indicates a problem your offer solves (step 1 is the lens). Otherwise it is noise.
- **Situations over demographics.** Describe what their team is dealing with day-to-day (the `implies` field), not what the company looks like on paper.
- **Score honestly.** A 4/10 is useful, it tells the downstream writer to go softer. Do not inflate.
- **Always include a fallback.**
- **Flag what you could not find.** Pages unavailable, JS-heavy site, thin data, say so plainly. Never fabricate to fill a gap.
- **Record facts trump website guesses.** If the record already knows something (`get_context`) or the user passes enrichment data, prioritize that over inferences from the site.
- **One job.** Signals only, no LinkedIn-post scraping (content-scan), no email writing. If asked, point at the right skill and stop.
- **The resolved record is the one source of truth.** Both outputs live in the record: the structured signals (`record_signal`) and the comprehensive brief (`save_note`). Never a separate local file. Signals are the source of truth for scoring; the brief is the source of truth for writing.

## What runs after this (not here)

1. **ICP scoring** from the `signal.*` features you recorded.
2. **content-scan** on ICP-qualified leads (over 70) only, adds deep Intent from LinkedIn posts.
3. **Your outreach skill** writes the message from the anchor signal.
