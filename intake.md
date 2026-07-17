# GTM OS Intake

This is the source of truth for your OS. `/onboard` reads this file to scaffold your `context/` files. Fill it in by typing, by talking (Wispr Flow or any dictation, just answer out loud), or by running `/onboard` for a guided conversation that does it with you.

**Before you start, two things make the result far better:**

1. **Your website.** `/onboard` asks for it first and scrapes it, then merges what it finds with your answers below. Have the URL ready.
2. **Anything you already have.** Old positioning docs, an ICP sheet, a pitch deck, a few real emails you have sent, a competitor teardown. Drop them in `references/` or just point Claude at them. You are not starting from a blank page. The more raw material you give it, the sharper every file comes out. Do not polish anything. Raw is better than edited.

Answer in your own words. There is no length limit and no wrong answer. You can edit this file and re-run `/onboard` any time.

---

## Q1: Tell us about you. Your story, what you have built, how you got here.

Who you are, the path that led to this, what you have shipped or sold before. This is the founder context that colours everything else. Talk for a minute.

```
(your answer)
```

---

## Q2: What do you sell, and why does it matter?

The offer, and the reason it exists. What is the thing, who is it for, what changes for them when they have it. One honest paragraph beats a polished pitch.

```
(your answer)
```

---

## Q3: Who is your ideal customer? The company, and the buyer inside it.

Two parts, both matter. The company profile (industry, size, what they do, what makes them a fit) and the actual person you sell to inside that company (their role, what they care about, what makes them pull the trigger).

```
(your answer)
```

---

## Q4: How do you talk about the problem, and what is your proof?

How you frame the problem you solve, the words you use for it, and the evidence that you are real (results, customers, numbers, a story). This becomes your messaging.

```
(your answer)
```

---

## Q5: Paste a few things you have actually sent. Unedited.

A cold email, a LinkedIn post, a page from your site, a DM that worked. Two or three is plenty. **Paste them raw.** Do not clean them up and do not write new ones for this. We read these for your voice and your language, and save them in `references/voice-samples/` so the OS can sound like you and not like a robot.

```
(paste sample 1)
```

```
(paste sample 2)
```

---

## Q6: How would you describe your own voice and tone?

Beyond the samples, in your own words: how do you want to sound? Direct, warm, technical, blunt, funny? Any words or phrases you always use, and any you never want to see. This plus the samples becomes `voice-and-tone.md`.

```
(your answer)
```

---

## Q7: What is your GTM stack?

Every tool that touches go-to-market. CRM, email sender, notetaker, enrichment, LinkedIn tooling, Slack, sheets, automation platforms. List what you actually use, even if it is messy. This seeds `connections.md` and your System of Record.

```
(your answer)
```

---

## Q7b: Where do you want your lead list to live?

The leads you find and enrich need a home you own: with their ICP score, their signals, and your tags. The recommended answer is your own Supabase Postgres, a database you own and can export any time, wired into this OS so the skills read and write it directly. You can also use Airtable or Google Sheets if that is where you already work, or start with a CSV. Which do you want, and if you already have a Supabase project, paste its project ref.

```
(your answer: supabase / airtable / sheets / csv, plus any project detail)
```

---

## Q8: How many clients or accounts are you running, and what is the motion?

Roughly how many accounts or clients you work right now, and how you go to market: inbound, outbound, account-based, partner-led, a mix. This tells the OS which skills and which cadence actually matter for you.

```
(your answer)
```

---

## Q9: Who are you measured against, and what is your edge?

The competitors or alternatives a buyer compares you to, and the one thing you do that they do not. Becomes `competitors.md`.

```
(your answer)
```

---

## Q10: What do you charge, and how?

Your pricing, even if it is rough or still moving. Plans, usage, per-seat, project-based, whatever it is. Becomes `pricing.md`.

```
(your answer)
```

---

When this file is filled (or when you have just talked through it with `/onboard`), the wizard scaffolds your Day-1 set: the `context/` files, your saved voice samples in `references/`, a populated `connections.md`, and a filled `CLAUDE.md`. Then it shows you where your stack slots into the System of Record and offers to wire in the resolved record underneath.
