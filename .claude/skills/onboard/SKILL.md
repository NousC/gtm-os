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

**Is this for you, or for a client?** If the user runs an agency or works several companies and says this run is for a client (they name one), you are onboarding that client, not the user's own business. Everything below is the same, with two changes: the questions are about the *client's* business (their website, their ICP, their voice), and you scaffold into `clients/<slug>/context/` instead of the root `context/` (see Step 4 and `clients/README.md`). The root `context/` stays the agency's own business. If no client is named, this is the user's own onboarding and you write root `context/` as normal.

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
- Q7 -> `connections.md`, then follow the agent note under Q7 and raise the resolved record (Step 5)
- Q8 -> shapes the cadence and which skills matter (note it in `CLAUDE.md`)
- Q9 -> `context/competitors.md`
- Q10 -> `context/pricing.md`

## Step 4: scaffold the Day-1 file set

Fill every `context/` file by merging the interview answers with the website scrape. Use the existing file templates as the structure. You are not filling a folder of files, you are compiling a wiki. Read `context/index.md` first so you build to its conventions.

**If this is a client run** (Step 1), scaffold into `clients/<slug>/context/` instead of the root `context/`: build the same wiki there (an `index.md` plus the pages), from the client's answers and their website. Pick a short lowercase `<slug>` from the client's name. Leave the root `context/` untouched, that is the agency's own. When you set up the lead store for a client (Step 5b), stamp their `<slug>` into the `client` column so their leads stay scoped. Everything else below is identical. Rules:

- The user's own words win over the scrape. Use the scrape to fill gaps and add detail, never to overwrite what they said.
- **Stamp each page as a wiki page.** Every `context/` file carries frontmatter. On fill, set `status: live` (it ships as `template`), set `updated` to today, keep the `about` tags, and list the real material behind the page in `sources` (a voice sample file, the site, an answer). Keep the `**Hubs:**` footer that links related pages.
- **Keep the hard split.** The wiki is about the user's business, never about an account. Do not write a prospect or customer fact into any `context/` page. Account facts belong in the resolved record (a `record` call), not a file. The one thing that may cross over is an anonymized market pattern, no company or person name.
- **Update the catalog.** After the pages are filled, refresh `context/index.md` so its one-line summaries match what each page now says. If you add a page, add its line. The index is read first by every later task, so it has to be true.
- Save the verbatim Q5 samples as individual files in `references/voice-samples/`, then write `context/voice-and-tone.md` as the distilled read of them. Point the file's `sources` at the samples.
- Fill `connections.md` from the stack in Q7. Mark each tool's status honestly (`not yet connected` is the default).
- Fill `CLAUDE.md`: replace every `{{placeholder}}` with the real detail. Keep the durable structure intact.
- Everything you write follows `context/voice-and-tone.md` once it exists. No em dashes, no filler, plain and direct.

Do not invent facts. If something is genuinely unknown after the interview and the scrape, leave a clear `(to fill)` marker rather than guessing.

On a re-run, some `context/` files may already hold real content. Do not blow them away. Show the user what you propose to change, merge the new material in, and keep anything still true. The point of re-running is to refresh, not to reset.

## Step 5: connect the stack, and draw the line clearly

Once the files are scaffolded, show the user their System of Record and Integration: which tools from Q7 landed in `connections.md` and what is still `not yet connected`.

Then raise the resolved record, following the agent note under Q7 in `intake.md`. That note holds the intent and the reasons. Do not read it aloud as a script, and do not paste it. Put it in your own words, name the tools they actually listed, and keep it to a short ask. The line to draw: their `context/` files are their own wiki (who they sell to, how they talk), and the resolved record is the other half, what happens inside their tools, resolved into one live account per person.

**Before you say anything about whether Nous is connected, check.** Seeing Nous tools in your session does not mean this OS is wired to Nous. The user may have it installed globally from other work, or installed but not signed in. Call `get_workspace_status` and branch on what comes back:

- No Nous tools available at all, or the call fails, means it is not connected. Make the ask.
- Tools available but no workspace or no auth means it is installed and signed out. Skip the ask and walk them through `npx -y @opennous/cli login`.
- Tools available and a workspace comes back means it is genuinely live. Skip the ask entirely and write `connected` into row 1.

Never write `connected` into `connections.md` on inference. Write it only after `get_workspace_status` returns a workspace.

If they say yes, run `claude mcp add nous -- npx -y @opennous/mcp` yourself, have them sign in with `npx -y @opennous/cli login`, re-check `get_workspace_status`, then update row 1 and offer to save a `references/nous-mcp.md` guide.

If they say no, leave row 1 as `not yet connected` and move on. Do not raise it again on a re-run.

### Step 5b: the lead store, where your leads live

Then ask where they want their **lead list** to live, the leads they find and enrich, with the ICP score, the signals, and their tags. The point is that they own it, not a vendor:

> "Where do you want your lead list to live? I recommend your own Supabase Postgres, a database you own. The only thing you do is connect your Supabase MCP server, then I push a ready-made schema into it for you, so every lead the find-and-enrich skills produce, with its ICP score, its signals, and your tags, lands in a table that is yours. You can also point me at Airtable or Google Sheets if that is where you already work, or I can keep it as a CSV to start. Which do you want?"

- **Supabase (recommended), and keep it low-friction.** The user does one thing: connect their Supabase MCP server (`claude mcp add supabase ...`, see `supabase/README.md`). Once it is connected, you do the rest, do not make them touch SQL:
  1. Ask whether to push the schema into an existing project or a fresh one. Their call.
  2. Push it yourself with the Supabase MCP `apply_migration`, reading `supabase/schema.sql`. Do not send them to the SQL editor or ask them to paste anything. After it runs, confirm the `lead_lists` and `leads` tables exist (a quick `execute_sql` on `information_schema`).
  3. Record Supabase as the lead store in `connections.md` (row 9), and offer to save `references/supabase-mcp.md`.
- **Airtable / Sheets:** record the tool and table in `connections.md` as the lead store; the skills append rows there.
- **CSV to start:** the skills write to `leads/`. Note they can graduate to Supabase any time, the schema is ready.

Whatever they pick, write it into `connections.md` so the find-and-enrich skills know where to save.

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
