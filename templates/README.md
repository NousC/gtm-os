# templates/

Your reusable scaffolds live here. A template is anything you want to start from
again instead of writing from scratch: a cold-email sequence, a LinkedIn message
frame, a campaign structure, a call script, a one-pager outline, a follow-up cadence.

One file per template. Name it by what it is, `kind-name.md`, so it is easy to find:
`cold-email-3touch.md`, `linkedin-connect-note.md`, `campaign-founder-led.md`,
`discovery-call-script.md`. Keep the reusable shape, mark the parts that change per use
with clear slots like `{first_name}`, `{signal}`, `{company}`.

Templates are shapes, not truth. How you talk lives in `context/voice-and-tone.md`;
who you sell to lives in `context/icp.md`. A template is the skeleton those fill. When
you save one, strip anything specific to the one account you wrote it for, that belongs
in the resolved record, never in a shared template.

## How the OS uses this folder

- **When you say "save this as a template"** (or "keep this sequence", "reuse this
  campaign shape"), the OS writes it here as `kind-name.md`, stripped of account
  specifics.
- **When you ask it to draft** a campaign, an email, a sequence, or any outreach, it
  checks `templates/` first and starts from a matching template if one exists, rather
  than from a blank page. It fills the slots from the resolved record and the context
  wiki, in your voice.

This is written into `CLAUDE.md` so a fresh session knows to look here without being told.
