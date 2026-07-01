---
name: audit
description: Use when the user wants a health check on their whole GTM setup, the system itself, not any single campaign, ad account, channel, or lead list. Reach for it whenever someone asks if their setup is built right, still accurate, or missing pieces: "audit my setup", "score my OS", "is my setup working", "what's my weakest layer", "find the gaps", "what should I fix", or "how's it looking after a week". Also use it to check whether the context files have gone stale or drifted. It grades the build across the four layers of The Agentic GTM System, runs a freshness check, and returns the top fixes by leverage. Read-only by default. Do NOT use it to audit one campaign or ad account, to score leads against an ICP, to rewrite positioning, to debug a skill, to edit connections, or to do first-time setup: those are other skills.
---

# /audit

The weekly check on whether the OS is built right and still true. Two passes: a four-layer scoreboard (is it built?) and a freshness check (is it still accurate?). Read-only unless the user asks you to fix something.

First, a sanity check. If the `context/` files are still untouched template stubs, this OS has not been onboarded yet. Do not score an empty kit and hand back a wall of zeros. Say so, and point the user at `/onboard`. The audit earns its keep once there is something real to audit.

## Pass 1: the four-layer scoreboard

Score each layer of The Agentic GTM System against its "in place" test. Read `THE-AGENTIC-GTM-SYSTEM.md` for the tests. For each layer, give a score out of 10 and one line on why.

- **System of Context.** Read every `context/` file. Are they filled with real, specific detail, or still template stubs and `(to fill)` markers? A fresh session should be able to answer "who do we sell to and how do we talk about it" from these files alone. Empty or generic files score low.
- **System of Record.** Is there a resolved record wired in (Nous or otherwise), or do account facts still live scattered across tools? Can the OS answer "what is the latest on account X" with real facts?
- **System of Integration.** Read `connections.md`. How many of the user's actual tools are connected versus `not yet connected`? Score on real coverage, not rows in a table.
- **System of Actions.** What skills and agents exist beyond the three that ship? Is the user triggering real workflows, or still doing everything by hand?

Show the four scores as a simple scoreboard. Total out of 40. Be honest. A flattering score helps no one.

## Pass 2: freshness check

Context rots. For each `context/` file, check two things:

1. **Cadence.** When was it last meaningfully changed (use git history if available, or judgement)? Positioning and ICP that have not moved in months on a young business are usually stale, not stable.
2. **Drift.** Does anything in `intel/decisions/log.md` or recent work contradict what a context file still says? A pricing change in the log that never made it into `pricing.md` is drift. Flag it.

List what looks stale or thin, with the specific file and the specific reason.

## Output: the top three fixes

Do not list twenty things. Rank by leverage and give the user exactly three moves, most impactful first. For each: what to do, which file or layer it touches, and why it matters most right now. A thin `icp.md` on someone running outbound beats a missing skill every time. Weight the fixes to what the user actually does (their motion from `CLAUDE.md`).

## Offer to fix

The audit is read-only. After the report, offer:

> "Want me to draft the fixes? I will propose updates for the stale files and you approve each one before it lands."

If yes, draft proposed updates (never silent overwrites), show them, and apply only what the user approves. Move any superseded version to `archives/` rather than deleting it. Log meaningful changes in `intel/decisions/log.md`.

Everything you write follows `context/voice-and-tone.md`. No em dashes, plain and direct.
