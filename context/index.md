---
type: index
status: live
updated: 2026-07-17
---

# index.md — the catalog

**Read this first. Then drill into the pages you need. Do not read the whole folder.**

This is the map of your context wiki. Every page, one line each. The point of an index is
that a fresh session reads this, finds the two or three pages a task actually needs, and
opens those, instead of loading everything. That is what keeps the OS fast and what makes
this a wiki instead of a pile of files. `/onboard` writes this map, and `/audit` checks it
for pages that are missing or orphaned.

---

## The context layer is an LLM wiki

Three layers sit under everything you do here. Keep them straight:

1. **Sources** (`references/`, and anything you bring). The raw material: your voice
   samples, an old deck, a pricing sheet, the notes from your site. You write these. The OS
   reads them and never rewrites them.
2. **The wiki** (`context/`, this folder). Compiled pages, one claim per page, kept current.
   The OS owns this layer: it writes the pages from your sources and your answers, keeps
   them cross-linked, and flags them when they drift.
3. **The schema** (`CLAUDE.md`). The rules the wiki runs on. Read once.

A page is a claim, and every claim should trace back to something real: a source you
brought, an answer you gave, a decision in `intel/decisions/log.md`. A page that asserts
with nothing behind it is an opinion, and `/audit` flags it.

## The hard split: this wiki is about you, not about them

The wiki holds what is true about **your** business: your positioning, your ICP, your
voice. The resolved record (Nous, if wired in) holds what is true about **everyone else**:
accounts, people, conversations, signals, scores. The files teach the system who you are.
The record teaches it who everyone else is.

The line is not soft. **Never write an account fact into a context page.** "Acme is on
HubSpot, Sarah is the champion" is a `record` call to the resolved record, not a line in a
file. If you are typing an account fact into `context/`, stop. And never write positioning
into the record except through the sync tools (`get_icp`, `sync_playbook`).

The one bridge is narrow. A customer conversation can produce a *market pattern*, which is
about you, not them: "founders keep saying their context dies between clients." That is
allowed into the wiki, anonymized, no company or person name. The evidence stays in the
record. Only the pattern comes across.

---

## The pages

Read the one the task touches. Positioning colours everything, so when in doubt start there.

- [[positioning]] `context/positioning.md` — what you sell and why it matters. The source of truth every other page expands.
- [[icp]] `context/icp.md` — the company you sell to and the buyer inside it. Every list-build, score, and outreach decision reads this.
- [[about-me]] `context/about-me.md` — who you are and the story. Colours the voice and the founder-led angles.
- [[messaging]] `context/messaging.md` — how you frame the problem and the proof behind it.
- [[voice-and-tone]] `context/voice-and-tone.md` — how you actually talk. The distilled read of the raw samples in `references/voice-samples/`.
- [[competitors]] `context/competitors.md` — who you are measured against and your wedge.
- [[pricing]] `context/pricing.md` — what you charge and how.

---

## How a page is built

Every page carries frontmatter and a Hubs footer, so the wiki is queryable and linked:

```yaml
---
type: context
status: live        # template until /onboard fills it, then live
updated: 2026-07-17
about: [icp, buyer] # what the page is about, for querying
sources: []         # the raw material behind the claims
---
```

At the foot of each page, a Hubs line links the pages it builds on: `**Hubs:** [[index]] ·
[[positioning]]`. Backlinks then answer "what did we build on the ICP" for free, which is a
question `/audit` needs.

## When a page outgrows one file

A page compounds by becoming a folder: a spine plus dated depth. When your `icp.md` stops
holding one clear ICP because you now sell to three segments, promote it to `context/icp/`:
`icp.md` stays the always-true spine that every skill reads, and dated `MMYY-topic.md` files
hold the depth and the evidence. The spine summarizes them. Same for any page that grows
past what one file can hold. Do not pre-create these folders. Grow into them.

---

**Hubs:** [[positioning]] · [[icp]]
