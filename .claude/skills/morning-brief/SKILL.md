---
name: morning-brief
description: Use at the start of the day, or whenever the user wants to get oriented on their go-to-market before they start working: "morning brief", "good morning", "what's on for today", "what should I focus on", "who do I need to follow up with", "catch me up on my accounts", "what went quiet". Pulls the user's accounts, follow-ups due, and accounts that have gone quiet into one short daily brief, reading the resolved record if connected plus the context files. Writes it to briefs/YYYY-MM-DD.md and surfaces the top three in chat. Do NOT use it for a single-account pre-call brief, a weekly campaign report, a calendar lookup, or an unrelated task that just happens to open with "good morning": those are other skills or plain answers.
---

# /morning-brief

The daily pull-together. One short brief that tells the user where their go-to-market stands this morning and what to do first. This is the System of Actions running on a cadence, the proof that the OS works while the user is not looking.

## What this skill does

Gathers the state of the user's go-to-market, decides what matters most today, and writes a short brief. It does not do the work, it points at the work.

## Step 1: gather

Pull from whatever is connected. Degrade gracefully when something is not.

- **The resolved record (if wired in).** This is the richest source. Pull recent activity: accounts with momentum, replies waiting, follow-ups due, and accounts that have gone quiet (cooled). If Nous or another record is in `connections.md`, use it.
- **Context.** Read `CLAUDE.md` for the user's motion and priorities, and `context/icp.md` so you weight the right accounts.
- **Decisions.** Skim recent `intel/decisions/log.md` entries for anything that changes today's focus.

If no record is connected yet, say so plainly and build the brief from context and priorities alone. Note that connecting the resolved record would make this brief much sharper.

## Step 2: decide

Do not dump everything you found. Decide. Pick:

- The **three things that matter most today**, ranked. Bias toward replies waiting and warm accounts cooling, since those decay fastest.
- The **follow-up queue**: who is due a touch and why.
- **What went quiet**: accounts that were live and have gone silent, worth a re-touch or a drop.
- One line of **voice of customer** if anything notable came back (a reply, a pattern), since that feeds the context files.

## Step 3: write the brief

Write to `briefs/YYYY-MM-DD.md` (create the `briefs/` folder if it does not exist). Keep it short, a one-screen brief, not a report. Structure:

```
# Morning brief: YYYY-MM-DD

## Top 3 today
1. ...
2. ...
3. ...

## Follow-ups due
- ...

## Gone quiet
- ...

## Worth noting
- ...
```

Then surface the top three in the chat so the user sees them without opening the file.

## The standard

Plain and direct, in the user's voice (`context/voice-and-tone.md`). No em dashes. A brief the user can read in thirty seconds and know exactly what to do first.
