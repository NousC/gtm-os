---
name: intel
description: Use weekly, or when the user wants to step back and turn the week's raw inputs into durable insight: "run my intel", "weekly intel", "what did we learn this week", "synthesize my meetings", "update my views", "what patterns are showing up", "capture this internal meeting". Reads the internal meeting substrate from the resolved record plus recent decisions and saved sources, then writes the synthesis into the intel/ layer: appends to intel/views/ where thinking moved, updates intel/patterns.md, and files internal meeting notes into intel/meetings/. The weekly companion to the daily /morning-brief. Do NOT use it for a GTM account review, a campaign report, a customer meeting brief (those touch the System of Record, not internal intel), or for first-time setup: those are other skills.
---

# /intel

The weekly synthesis loop. It takes the raw inputs from the week (internal conversations, decisions, things you saved) and turns them into durable, timestamped insight in the `intel/` layer. Where `/morning-brief` orients you for the day, `/intel` makes the OS smarter over the long run.

Read `intel/README.md` first so the layer's structure is fresh.

## The core idea

Raw substrate lives in your tools and your resolved record (transcripts, full notes). Your job here is not to store more raw material. It is to write the **synthesis**: what changed, what is recurring, what you decided. Interpreted facts only.

## Step 1: gather the week's inputs

- **Internal meetings.** Pull recent conversations with internal people from the resolved record. Internal people are the ones the user has marked as team (see "Who is internal" below). Get the transcripts or notes from the last week.
- **Decisions.** Read the recent entries in `intel/decisions/log.md`.
- **Sources.** Read anything new in `intel/sources/`.
- **Current views.** Read the existing `intel/views/` files so you know what the thinking *was*, and can spot where it moved.

If there is no resolved record connected yet, work from what is in the repo (decisions, sources, and any meeting notes the user dropped into `intel/meetings/` by hand). Say plainly that connecting the record would let you pull internal transcripts automatically.

## Step 2: write the synthesis

Do not dump. Decide what actually moved, then write it.

- **Views that shifted.** For each belief or number where the week changed your read, append a new dated entry to the top of the relevant `intel/views/` file (create the file if the topic is new). Say what you now think and why the week moved you. Keep the old entries untouched below, that history is the point.
- **Internal meetings.** For each internal conversation, write or refine a distilled note in `intel/meetings/` (dated, the format in that folder's README). Pull the real decisions out into `intel/decisions/log.md` and suggest logging them.
- **Patterns.** Update `intel/patterns.md` with anything you saw for the third time across meetings, sources, and accounts. A pattern is a repeat, not a single event.

## Step 3: surface it

In chat, give the user the short version: the two or three views that moved this week, any new pattern, and any decision worth logging. The files are the durable record, the chat is so they see it without opening anything.

## Who is internal

The user marks teammates so internal people never get treated as prospects. Two ways, depending on the setup:

- **If the resolved record supports an internal or team tag,** read the tagged people and treat their meetings as internal intel. This is the clean path.
- **If not yet,** the user keeps a short list of teammate names and emails (in `intel/team.md` or noted in `CLAUDE.md`). Read that list and pull those people's notes from the record.

Either way, internal people feed `intel/`, never the GTM motion (no scoring, no lists, no outreach).

## The standard

Plain and direct, in the user's voice (`context/voice-and-tone.md`). No em dashes. Synthesis, not transcription. A `views/` entry someone can read in ten seconds and understand how the thinking moved.
