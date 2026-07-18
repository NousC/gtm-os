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

By hand as you work. When you decide something, log it in `decisions/log.md`. When a read shifts, append a dated entry to a `views/` file. When a theme repeats, add it to `patterns.md`. `/audit` reads this layer and flags what has gone stale or thin, and `/morning-brief` pulls the recent decisions into the daily brief.
