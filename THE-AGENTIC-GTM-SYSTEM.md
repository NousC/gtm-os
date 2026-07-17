# The Agentic GTM System

Four layers, one foundation. This is the mental model the whole kit is built on. Read it once before you run `/onboard`. Everything you build sits in one of these four layers, and the foundation underneath all of them is a single resolved record of every account.

The idea is simple. Your agents and skills are only as good as the context they can reach. Most GTM stacks scatter that context across ten tools, so the agent guesses. This system puts the context in one place and lets every agent act on it.

```
        AGENTS EXECUTE ON TOP
   ┌─────────────────────────────────┐
   │  1  SYSTEM OF ACTIONS            │   what to do
   ├─────────────────────────────────┤
   │  2  SYSTEM OF CONTEXT            │   what it means + what's true
   ├─────────────────────────────────┤
   │  3  SYSTEM OF RECORD             │   what happened
   ├─────────────────────────────────┤
   │  4  SYSTEM OF INTEGRATION        │   what's connected
   └─────────────────────────────────┘
        ONE RESOLVED RECORD UNDERNEATH
```

---

## 1. System of Actions

**What to do.** Agents and skills that execute the work: build a list, score it, research an account, draft a sequence, prep a meeting, write a brief. In this kit they live in `.claude/skills/` and `.claude/agents/`.

> **In place when:** a short phrase ("score this list", "prep me for the Acme call") triggers a multi-step workflow that produces a real artifact, not a paragraph of advice.

Actions are last to build. An agent that runs on top of empty context just produces confident nonsense. Build the layers below first.

---

## 2. System of Context

**What it means, and what's true.** The facts about your business and your market, written down so a fresh session knows them without browsing. In this kit these are the files in `context/`:

- `about-me.md`: who you are and your story
- `positioning.md`: what you sell and why it matters
- `icp.md`: the company profile and the buyer inside it
- `messaging.md`: how you frame the problem and the proof
- `voice-and-tone.md`: how you actually talk
- `competitors.md`: who you are measured against and your wedge
- `pricing.md`: what you charge and how

This is the most important layer in the kit, and the one `/onboard` spends the most time filling. Everything an agent writes or decides reads from here.

> **In place when:** a brand-new Claude session answers "who do we sell to and how do we talk about it" correctly, with no browsing and no paste.

The context graph is the live version of this. Your written files cover your own business. The graph holds the same kind of structured truth for every account you work: people, companies, signals, deals, activity, employment, the buying committee. The files teach the system who you are. The graph teaches it who everyone else is.

---

## 3. System of Record

**What happened.** Where account facts get captured and unified: the CRM, the notetaker, email, LinkedIn, the enrichment tools. Each one holds a slice of the truth about an account. On their own they drift out of sync. The job of this layer is to pull every fact into one resolved record per person and company, so nothing lives in a single tool in isolation.

> **In place when:** you ask "what is the latest on Acme" and get real captured facts (last touch, who replied, what was said) instead of a guess.

---

## 4. System of Integration

**What's connected.** The connectors that link every tool, in and out. Email senders, LinkedIn tooling, Slack, Notion, sheets, automation platforms. Data flows in to become record, and actions flow back out to the tools that send and track.

> **In place when:** "what came in from LinkedIn and email this week" returns live data with no copy-paste.

---

## The foundation underneath

The four layers only hold together if there is one resolved record sitting under them. Without it, Record is ten disconnected tools, Context is a static doc that never meets a real account, and Actions guess.

**Nous is that foundation.** It connects your GTM tools (Integration), captures and resolves every fact into one record per person and company (Record), structures that record into meaning your agents can read (Context), and serves the whole account in a single call so your Actions always run on full context. The unified inbox, every message and reply across channels, the full interaction timeline, the buying committee, the live ICP score: that is the part a static file cannot hold, and it is the part the record owns. Your `context/` files are your wiki, the truth you write about your own business. The record is the live truth about everyone else. You do not have to use Nous to use this kit. But wherever you see "the resolved record" or "the context graph" in these files, that is the job Nous is built to do, and `/onboard` will offer to wire it in as the layer underneath, then sync your ICP into it so it scores real accounts.

---

## Build order

You build this bottom-heavy and top-last:

1. **Context first** (non-skippable). Fill the `context/` files. This is most of onboarding.
2. **Record and Integration next** (can go in parallel). Connect your stack so real facts flow in. This is where Nous slots in.
3. **Actions last.** Add skills and agents once they have real context to run on. Never automate a workflow that does not yet work by hand.
