---
name: content-scan
description: The deep Intent layer. Scrape a prospect's recent LinkedIn posts via Apify, read them semantically for the themes that map to your offer, then record a distilled Intent signal on the account and save the quoted evidence as a note for personalization. This is the second enrichment pass, run AFTER signal-scan and ICP scoring, and ONLY on ICP-qualified leads (about 70+) because it costs money per profile. Use it when the user says "scrape their posts", "what's [prospect] been posting about", "find intent in their LinkedIn content", "deep-enrich my qualified leads", or "has this list been talking about [theme]". It does one thing: posts into Intent. It does not scan websites (that is signal-scan) and does not write outreach. For a single 1:1 pre-meeting brief, use a meeting-brief instead.
---

# Content scan

## One job

Scrape a prospect's recent **LinkedIn posts** and turn them into **Intent**, the strongest
evidence that they are consciously working the problem your offer solves. Two outputs, both
on the account:

1. **A distilled Intent signal** with `record_signal` (`signal.intent`, scored, with an
   angle drawn from a real post). The feature that feeds the ICP model and shows on the
   Signals tab.
2. **The evidence as a note** with `save_note` (the quotes, post links, and themes). Rich
   for personalization; your outreach skill reads it. Shows under the Notes tab.

No local file, the resolved record is the one source of truth.

This runs **after** signal-scan and ICP scoring, **only on ICP-qualified leads (about 70+)**,
because it is paid (Apify, about $0.005 per post). It is the deep layer; signal-scan is the
free first pass.

The boundary, on purpose:
- **This skill:** LinkedIn posts into an Intent signal plus an evidence note.
- **signal-scan (before this):** website plus record data into the six signal classes, free.
- **Your outreach skill (after this):** writes the message. Not here. See `EXPANSIONS.md`.

## How to invoke

`/content-scan`, or "scrape posts for my ICP-qualified leads", "what's Georgi been posting
about", "has this list talked about cold email being broken".

Resolve from the prompt:
- **Target:** one prospect, or a set of ICP-qualified leads. **Resolve by LinkedIn URL or email, never the display name** (name lookup 404s).
- **Theme** (optional): a specific topic to hunt for. If omitted, scan for the themes that map to your offer (from the ICP wiki and the GTM profile).
- **Count:** posts per profile (default 20).

## Make it yours (first run)

Before the first scrape, fit the intent lens to the user's offer. Read `context/index.md`, then `context/positioning.md` and `context/icp.md` for the problem they solve. Then confirm with the user, once:

- The two or three themes that count as real intent for them (the problems the offer touches, in their words).
- Any stance or topic that looks on-theme but is not a buying signal for them.

Save the themes into `context/messaging.md` (or `context/icp.md`), so this and every run reads the same lens. Skip anything the wiki already answers.

## First-run setup

- **The resolved record:** try `get_context`. Not connected, set up the MCP (see
  signal-scan). Without it the scan still reads posts and reports, but nothing persists or
  scores, say so.
- **Apify:** needs `APIFY_API_TOKEN` (or `APIFY_TOKEN`). Missing: "I read posts through
  Apify, about $0.005 per post (about $0.10 per profile for 20). Add the token:
  `export APIFY_API_TOKEN=apify_api_xxx` (apify.com, Settings, Integrations)."

Actor: `apimaestro/linkedin-profile-posts` (URL form `apimaestro~linkedin-profile-posts`),
no LinkedIn cookies needed.

## Core philosophy

**Intent is what they say in their own words.** Quote real posts, never paraphrase into a
fake signal. If they have not posted on-theme, say so, silence is information.

**Match semantically, not by keyword.** "We're ripping out our playbooks for Claude agents"
matches "AI-first GTM" without the phrase. A passing "AI" mention in an unrelated post does not.

**Judge against your offer.** A post is Intent only if it touches the problem you solve
(load the ICP wiki first). Otherwise it is noise.

**Spend on keepers.** Paid, so ICP-qualified only, with a cost preview.

## The process

### 1. Load the offer and ICP lens from the context wiki

The ICP lives in the user's own wiki, not a web form. Read `context/index.md` first, then
**read `context/icp.md`** and `context/positioning.md`, the problem you solve defines which
themes count as Intent. If the record is connected and holds a learned model, `get_icp_model`
refreshes it (`get_icp` re-syncs if the file changed), and `get_gtm_profile` fills gaps the
file does not cover.

### 2. Resolve the prospect and gate on ICP

`get_context` by **email or LinkedIn URL** (never name) confirms ICP fit at about 70 or
higher and gives the `linkedin_url`. Skip leads below the threshold, they do not earn a paid
scan. For a list, show the cost preview before spending:
> "N ICP-qualified leads, scan posts about $X (N × 20 × $0.005). Run it?"

### 3. Scrape recent posts (paid)

One Apify run per profile, in parallel:

```bash
curl -s -X POST \
  "https://api.apify.com/v2/acts/apimaestro~linkedin-profile-posts/run-sync-get-dataset-items?token=$APIFY_API_TOKEN&timeout=120" \
  -H "Content-Type: application/json" \
  -d '{ "username": "<linkedin-username-or-url>", "total_posts": 20 }'
```

`username` works with a bare handle (`georgi-furnadzhiev`) or a full profile URL. If a run
returns 400 or empty, try `profileUrl` or `profileUrls` instead, adapt and retry once. Do
not loop paid runs. Reshared posts count, read them too.

### 4. Read for Intent (semantic)

> **Capture SPECIFIC NAMED FACTS, not abstractions. This is the whole point.** An outreach
> skill can only NAME what you capture. If you write "they post about outbound", the email
> comes out abstract and gets deleted. Pull the concrete, nameable things: **exact numbers**
> ("170k emails/mo", "20+ meetings in 90 days", "36% positive reply rate"), **named tools**
> (Clay, Smartlead, Apollo, not "their stack"), **named clients, companies, case studies**,
> **named verticals or ICPs**, and the **specific public stances** they have taken (the
> actual position, e.g. "argues open rates are vanity, only positive replies count", not the
> vague "cares about quality"). A fact you can drop into a sentence verbatim is usable. A
> theme is not.

Two reads:
- **What they post about overall:** their dominant themes and voice, plus the specific named stances they repeat (named, observational, never quoted back).
- **On-theme matches:** for each post that touches the problem your offer solves, capture the **date**, the **specific named facts in it** (numbers, tools, claims), the **post URL**, and a **one-line why-it-matches**. The quote is for your understanding; what the writer uses is the named facts, never the quote cited back at them.

Pick the **anchor**, the single strongest, most recent on-theme post.

### 4b. Competitor and switching signals (a distinct intent class)

While reading, watch for the prospect **naming a competitor or a tool in your category**,
praising it, complaining, comparing, or signalling they are evaluating or switching. That is
a sharper, time-sensitive intent than a generic pain post. When you find a genuine one,
record it on the **person** as a decaying intent event:

```
record(focus: <email/linkedin>, observations: [{ kind: "event",
  property: "interaction.competitor_engagement",
  value: { competitor: "<named tool/competitor>", stance: "evaluating|frustrated|praising|switching", evidence: "<the exact line>", post_url: "<url>" },
  source: "content-scan" }])
```

Only on a real, named mention, never infer one.

### 5. Record a SHORT signal and a LONGER structured note (both on the record, no file)

Different jobs, different lengths.

- **The Intent signal** with `record_signal` (**keep it short**, it is a glanceable line on
  the Signals tab). It feeds the intent score (which decays over about 3 weeks, so recency
  and score matter): `signal_class: "intent"`, `detected` is ONE tight sentence naming the
  theme (a 3 to 6 word quote fragment is fine, not a paragraph), `implies` one short clause,
  `score` 0 to 10 by how clearly and recently they work the problem, `approach`, `angle` one
  line in their words. The detail lives in the note, not here.

- **The evidence note** with `save_note` (**the real research**, this is what your outreach
  skill reads): `focus` (email or URL), `type: "research"`, `title: "{name} - LinkedIn Post
  Scan"`. Put the structured report in `content`:

  ```markdown
  # LinkedIn post scan, {name}

  > {1-2 sentences: the dominant theme they keep returning to and the single strongest hook
  > this scan surfaced for outreach.}

  Scanned: {date}
  Theme: {theme, the problem your offer solves, in your words}
  Profile: {linkedin_url}
  Headline: {their LinkedIn headline if available}
  Posts reviewed: {n}
  Direct matches: {m}

  ---

  ## What they post about (voice and themes)
  {2-4 sentences: their dominant themes, the cadence of what they publish, and their voice,
  how they write (contrarian? data-led? teacher? story?). This is the copy fuel: the outreach
  skill mirrors this voice. Quote a phrase or two they actually use.}

  ## Direct matches
  ### {date}, [post]({post_url})
  > {1-3 sentence quote in their own words, the real line, not a paraphrase}

  **Why it matches:** {one line, the specific link to the problem you solve}
  **Copy hook:** {one line, the exact angle the email can echo back to them}
  {repeat per on-theme post, strongest and most recent first}

  ## Adjacent signals
  {posts that touch the space without being dead-on, same shape plus a "Why it's adjacent"
  line. Only if any.}

  ## Voice and phrasing bank
  {3-6 verbatim short phrases they actually use, the vocabulary the email should sound like.
  This is what makes the copy sound like a peer, not a vendor.}

  ## Anchor
  {the single strongest, most recent on-theme post, date plus one-line why it is the lead
  angle for outreach.}

  ## No-match summary
  {only if zero on-theme posts, one sentence on what they DO post about, so you can judge
  whether the theme is truly absent or just framed differently.}
  ```

  **Make it comprehensive**, this note is the entire input an outreach skill compiles into
  copy. More detail means better, more personal emails. Never thin it out.

### 5b. Write the intent to your lead store

If the leads live in your own lead store (Supabase, see `supabase/README.md`), add the intent
signal to that lead's row so the store carries it alongside the company signals from
signal-scan. Via the Supabase MCP:

```sql
update leads
set signals = signals || jsonb_build_object('intent', jsonb_build_object(
      'detected', '<one tight sentence>', 'score', <0..10>,
      'angle', '<one line in their words>', 'anchor_post', '<url>')),
    tags = case when not ('has-intent' = any(tags)) then array_append(tags, 'has-intent') else tags end
where lower(linkedin_url) = lower('<linkedin_url>')  -- or match on lower(email)
   or lower(email) = lower('<email>')
returning id;   -- <LEAD_ID>

-- log the post scrape as a waterfall event
insert into enrichment_events (lead_id, field, provider, status, credits, ran_at)
values ('<LEAD_ID>', 'intent', 'apify', 'hit', 0.10, now());
```

The evidence note stays in the resolved record (step 5); the store holds the glanceable
intent plus a `has-intent` tag so you can filter the list to the warmest leads. If no store is
configured, skip this and keep the signal on the record only.

### 6. Report back (chat only)

Per profile: `{name}: {m} on-theme posts, anchor: "{short quote}"` or `{name}: no on-theme
posts (they mostly post about {X})`. Note the strongest find. Do not paste the full evidence,
it is on the record.

## Running at scale, gate once, scout once, fan out, assemble

Same scout, fan out, assemble shape as signal-scan, with **two gates up front** because this
skill spends money. For a single prospect, run steps 1 to 6 inline. For a **set of qualified
leads**, fan out, profiles are independent and all writes go to the record per-entity.

1. **Gate and scout once (you, the main agent).** Filter to **ICP 70 or higher only**
   (step 2). Load the ICP lens a **single time** (step 1). Show **one cost preview and get
   one yes** for the whole batch, never let sub-agents ask individually:
   > "N qualified leads × 20 posts about $X (N × 20 × $0.005). Run it?"
2. **Fan out, one sub-agent per qualified profile, capped at about 8 to 10.** Paste the ICP
   lens in so none re-fetch:
   > "Run content-scan on this one profile: `<linkedin-url/email>`. ICP lens: `<paste>`. Do
   > steps 3 to 5: Apify scrape, read posts semantically for on-theme Intent, `record_signal`
   > (`signal.intent`) and `save_note` the evidence. Return only: `{name}: {m} on-theme,
   > anchor "{quote}"` (or no on-theme posts)."
   Use the `gtm-operator` sub-agent (or a general one), batch the rest.
3. **Assemble (you).** Collect the one-liners, call out the strongest finds.

Confirmation happens **once, at the top**, sub-agents only ever run on already-approved,
already-qualified leads. For a **handful (5 or fewer)** run inline.

## Hard rules
- **Quote, never invent.** No Intent without a real post behind it. No on-theme posts, say so plainly (the silence is the finding).
- **Semantic, not keyword.** Match meaning, ignore passing mentions.
- **ICP-qualified only, confirm before spending.** Never run the paid scrape on sub-threshold leads or without a cost preview and a yes.
- **One job.** Posts into Intent. No website scan (signal-scan), no message writing. Profiles only, not company pages.
- **Resolve by URL or email, never name.**
- **The resolved record is the one source of truth.** Signal and note on the account, no local file.

## What runs after this

**Your outreach skill** writes the message from the anchor signal plus the post-scan quotes,
real words into a message that sounds like a peer. See `EXPANSIONS.md` for adding one.

## Cost

About $0.005 per post, so about $0.10 per profile (20 posts), ICP-qualified leads only,
after confirmation. 50 qualified leads is about $5.
