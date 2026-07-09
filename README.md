# GTM OS: a go-to-market operating system for Claude Code

A free, open starter kit that turns Claude Code into your go-to-market operating system. You clone it, run `/onboard` once, and Claude learns your business, your ICP, your voice, and your stack. From then on every GTM task it does for you (research an account, build a list, draft a sequence, prep a call, write a brief) runs on your real context instead of generic guesses.

It is built for the people who run go-to-market: founders doing their own outbound, GTM engineers, RevOps leads, and agencies running many client stacks.

---

## The idea in one line

> Your agents are only as good as the context they can reach. GTM OS gives them one place to reach it.

Most GTM stacks scatter the truth about an account across ten tools, so the agent guesses. This kit puts your context in writing, connects it to a live record of every account, and lets every skill act on the whole picture.

---

## The two things to read first

Two reference files sit at the root. Read them before you do anything else. They are the knowledge layer, not config.

- **`THE-AGENTIC-GTM-SYSTEM.md`**: the architecture. Four layers (Actions, Context, Record, Integration) and the one resolved record underneath them.
- **`THE-GTM-PLAYBOOK.md`**: the motion. The end-to-end account-based loop that runs on top: Find, Signal, Score, Personalise, Send, Reply, Learn.

Architecture first, then the motion. Once both make sense, the folder structure stops looking like folders and starts looking like a system.

---

## Quick start

1. **Clone the repo** into a working folder.
2. **Open it in Claude Code** and run `/onboard`. Have your website ready. If you use Wispr Flow or any dictation, just talk through the answers. If you already have positioning docs, an ICP, a deck, or old emails, point Claude at them. The more raw material you give it, the better the result. Takes about 15 to 20 minutes.
3. **`/onboard` scaffolds your context.** It scrapes your site, merges that with what you said, and fills the `context/` files and `connections.md`. You review and correct.
4. **Connect your stack.** `/onboard` shows where your tools slot into the System of Record and Integration, and offers to wire in the resolved record underneath (see below).
5. **Use it.** Bring real accounts and real tasks. Run `/audit` after a week to see where the context is thin or stale. Run `/morning-brief` to get the day pulled together for you.

---

## What ships

Four skills, kept lean on purpose. You add more as you grow (see `EXPANSIONS.md`).

| Skill | When to run |
|---|---|
| `/onboard` | Day one, right after clone. Asks about you, your ICP, your voice, and your stack, scrapes your site, and scaffolds the `context/` files. Re-run any time after editing `intake.md`. |
| `/audit` | After a week, then weekly. Scores your build against the four layers and flags context that has gone stale or thin. |
| `/morning-brief` | Daily. Pulls your accounts, your follow-ups, and what went quiet into one brief so you start the day already oriented. |
| `/intel` | Weekly. Turns the week's internal meetings, decisions, and saved sources into durable insight in the `intel/` layer. |

---

## The context files

The heart of the kit. `/onboard` fills these from your answers and your website. They are what every skill reads.

```
context/
├── about-me.md        you, your story, what you have built
├── positioning.md     what you sell and why it matters
├── icp.md             the company profile and the buyer inside it
├── messaging.md       how you frame the problem and the proof
├── voice-and-tone.md  how you actually talk, with examples in references/
├── competitors.md     who you are measured against and your wedge
└── pricing.md         what you charge and how
```

Your raw voice samples (real emails, posts, pages, unedited) live in `references/voice-samples/`. `voice-and-tone.md` is the distilled read of those samples.

---

## The resolved record underneath

The four layers need one resolved record of every account sitting under them, or Record is just ten disconnected tools and your agents guess. **Nous is built to be that record.** It connects your GTM tools, resolves every person and company into one record, structures it into context your agents can read, and serves the whole account in a single call. The kit works without it, and wherever these files say "the resolved record" or "the context graph" that is the job Nous does. `/onboard` will offer to wire it in. It is an option, not a requirement.

---

## Repo layout

```
gtm-os/
├── README.md
├── CLAUDE.md                   your operating manual, filled by /onboard
├── intake.md                   the source of truth for /onboard, edit and re-run any time
├── THE-AGENTIC-GTM-SYSTEM.md   reference: the architecture
├── THE-GTM-PLAYBOOK.md         reference: the motion
├── EXPANSIONS.md               what to add as you grow
├── connections.md              registry of every tool your OS can reach
├── context/                    the files that make it yours, filled by /onboard
├── references/                 voice samples and any docs you bring
├── intel/                      where the OS gets smarter over time
│   ├── decisions/log.md        append-only record of what you decided and why
│   ├── views/                  how a belief or number drifted over time, dated
│   ├── meetings/               internal team and co-founder notes, distilled
│   ├── sources/                external resources worth keeping, distilled
│   └── patterns.md             recurring themes across meetings, sources, accounts
├── archives/                   old files, do not delete, move here
└── .claude/
    ├── skills/                 onboard, audit, morning-brief, intel
    └── agents/                 your first agent goes here
```

---

## License

MIT. Use it, fork it, build on it. If it makes your go-to-market sharper, that is the point.
