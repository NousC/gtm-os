---
name: onboard
description: First-run setup wizard for a freshly cloned GTM OS. Use whenever someone wants to start, set up, initialize, onboard, or get going, or any time they want Claude to learn their business so it stops guessing. Triggers include "set me up", "onboard me", "let's get started", "fill in my OS", "I just cloned this, how do I start". Asks for the user's website and scrapes it, runs the GTM intake interview (or reads a filled intake.md), and scaffolds the Day-1 file set: the context/ files, voice samples saved to references/, a populated connections.md, and a filled CLAUDE.md. Idempotent, re-run any time after editing intake.md. Do NOT use it to audit an existing setup, to edit a single context file, or to wire up one tool: those are other skills.
---

# /onboard

The setup wizard for GTM OS. One run takes a brand-new clone and turns it into an OS that knows the user's business, ICP, voice, and stack. Re-runnable any time after they edit `intake.md`.

## What this skill does

1. Reads `intake.md`, `THE-AGENTIC-GTM-SYSTEM.md`, and `THE-GTM-PLAYBOOK.md` so you understand the system you are setting up.
2. Gets the user's website and any existing files, scrapes the site, and uses both as raw material.
3. Runs the intake interview (unless `intake.md` is already filled).
4. Scaffolds the Day-1 file set from everything gathered.
5. Shows the user where their stack fits, draws the line between their wiki and the resolved record, and offers to wire the record in.
6. Syncs the ICP and context into the record so it scores real accounts. Filling the files is not the finish line, the ICP living in the record is.

## Step 1: orient

Read `intake.md`. If the question blocks already have real answers, skip the interview and go straight to scaffolding (Step 4) using what is there plus the website. If it is still the blank template, run the interview.

Read both reference files so your questions and your output match the framework.

## Step 2: website and existing files (do this first, always)

Before any questions, ask two things:

> "First, what is your website? I will read it and pull what I can so you have less to type."
>
> "Second, do you already have anything written? Old positioning, an ICP sheet, a deck, a few real emails you have sent? Drop them in `references/` or just paste them. The more raw material you give me, the sharper this comes out. Do not polish anything."

Scrape the website with whatever fetch or browser tool you have. Pull: what they sell, who it seems to be for, the language they use, named customers or proof, pricing if it is public, and any competitor framing. Hold this as draft material to merge with their answers. The user's own words always win over the scrape when they conflict.

If you have no way to fetch the page (no fetch tool is available in this install), say so plainly and ask the user to paste their homepage and about page instead. Do not pretend to have read a site you could not reach.

Save any files the user brings into `references/`.

## Step 3: the interview

Tell the user up front:

> "Ten questions. Answer in your own words, no length limit. If you have Wispr Flow or any dictation, just talk, do not type. We can go as fast or slow as you want, and you can edit and re-run this any time."

Walk the ten questions from `intake.md` in order. Q1 (about you) first, it colours everything. For Q5, make sure the samples are pasted verbatim and never write new ones for them. If an answer is thin, ask one sharpening follow-up, not five. Write each answer back into `intake.md` as you go so nothing is lost.

The questions map to files like this:

- Q1 -> `context/about-me.md`
- Q2, Q4 -> `context/positioning.md`
- Q3 -> `context/icp.md`
- Q4 -> `context/messaging.md`
- Q5 -> `references/voice-samples/` (verbatim) + `context/voice-and-tone.md`
- Q6 -> `context/voice-and-tone.md`
- Q7 -> `connections.md`
- Q8 -> shapes the cadence and which skills matter (note it in `CLAUDE.md`)
- Q9 -> `context/competitors.md`
- Q10 -> `context/pricing.md`

## Step 4: scaffold the Day-1 file set

Fill every `context/` file by merging the interview answers with the website scrape. Use the existing file templates as the structure. Rules:

- The user's own words win over the scrape. Use the scrape to fill gaps and add detail, never to overwrite what they said.
- Save the verbatim Q5 samples as individual files in `references/voice-samples/`, then write `context/voice-and-tone.md` as the distilled read of them. Point the file at the samples.
- Fill `connections.md` from the stack in Q7. Mark each tool's status honestly (`not yet connected` is the default).
- Fill `CLAUDE.md`: replace every `{{placeholder}}` with the real detail. Keep the durable structure intact.
- Everything you write follows `context/voice-and-tone.md` once it exists. No em dashes, no filler, plain and direct.

Do not invent facts. If something is genuinely unknown after the interview and the scrape, leave a clear `(to fill)` marker rather than guessing.

On a re-run, some `context/` files may already hold real content. Do not blow them away. Show the user what you propose to change, merge the new material in, and keep anything still true. The point of re-running is to refresh, not to reset.

## Step 5: connect the stack, and draw the line clearly

Once the files are scaffolded, show the user their System of Record and Integration: which tools from Q7 landed in `connections.md` and what is still `not yet connected`.

Then draw the line the whole system turns on, plainly and without selling. There are two halves and they do different jobs:

> "What you just built is your own wiki: who you sell to, how you talk, what you charge. That is yours, it lives in these files, and you own it. The other half is what happens inside your tools, the part a static file can never hold: every person, company, conversation, and reply across your CRM, your inbox, LinkedIn, and your meetings, resolved into one live record per account and scored on your real outcomes. That half is the resolved record, and Nous is built to be it. Your files teach the system who you are. The record teaches it who everyone else is. The two only pay off together: your ICP is just words in a file until the record scores real accounts against it, and the record is just raw activity until your context tells it what any of it means."

Then, if the record is not wired in yet, offer to connect it:

> "Want me to wire in the record? It is one MCP command, and it is what turns your files from a document into a working system. Optional, your OS runs either way, but everything below gets sharper once it is in."

If they say yes, point them at the `claude mcp add nous` steps in `connections.md` and offer to save a `references/nous-mcp.md` guide.

## Step 6: sync your wiki into the record (the finish line)

Filling the files is not the finish line. The finish line is your ICP and your context living in the record, so it scores real accounts against them. A context file that never reaches the record is a document, not an operating system.

If the resolved record is connected:

- Sync the ICP and the context you just wrote into the record so the score runs on it. With Nous, that is `get_icp` (file to record) for the ICP and context, and `sync_playbook` for any playbook. Do this now, in this run. This is what the `context-sync-nudge` hook will keep reminding you to do every time you edit a file later.
- Confirm it landed: pull it back and show the user the record now holds their ICP. That round trip is the proof the system is live.

If the record is not connected yet, say plainly that this is the one step still open, and that the moment they wire it in, syncing the ICP is the first thing to do. Leave them a clear note in `CLAUDE.md` so it is not forgotten.

## Step 7: hand off

Tell the user what got built, in one short list, and whether the ICP made it into the record or is still waiting on the connection. Then point them at the next moves: bring a real account and a real task, run `/audit` after a week to see where the context is thin, and run `/morning-brief` to start the day oriented.

## The standard for everything you write

Read `context/voice-and-tone.md` (once it exists) before writing any prose into the files. Plain, direct, no corporate filler, no em dashes anywhere. The files should read like the user wrote them, because soon every skill will speak in that voice.
