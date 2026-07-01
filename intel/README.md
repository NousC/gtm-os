# Intel

The Intel layer is where the OS gets smarter over time. The `context/` files hold what is true about your business right now. Intel holds what you are *learning*: the decisions you make, the resources you gather, the conversations you have, and how your thinking shifts week over week.

The split that keeps this from rotting: your tools and your resolved record hold the raw substrate (transcripts, notes, full history). Intel holds the **synthesis**, the interpreted version a human or an agent can act on. Never dump raw exports here. Interpreted facts only.

## What lives where

- **`intel/decisions/log.md`** is the choices you made, point in time, with the why. Append-only, never edited.
- **`views/`** is how a belief or a number *drifted* over time. One file per thing you track (`icp-thesis.md`, `pricing-view.md`). Append-only dated entries, newest on top, so you can scroll the evolution. This is not a decision, it is the moving understanding behind decisions.
- **`meetings/`** is your internal team and co-founder conversations, distilled. One dated file per meeting (`0629-roadmap.md`). Customer and prospect meetings belong in the resolved record (System of Record), not here. This folder is for the inside of the company.
- **`sources/`** is external resources worth keeping: articles, videos, competitor moves, swipe. Dated, distilled to why it matters, not pasted in full.
- **`patterns.md`** is the recurring themes that surface across meetings, sources, and accounts. The signal under the noise.

## How it fills

By hand as you work, and through `/intel` once a week. `/intel` reads the meeting substrate from your resolved record, plus recent decisions and sources, and writes the synthesis: it appends to the `views/` files where your thinking moved, updates `patterns.md`, and files new internal meeting notes. It is the weekly companion to the daily `/morning-brief`.
