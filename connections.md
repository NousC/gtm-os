# Connections

Registry of every tool this OS can reach. This is your System of Integration. `/onboard` fills it from your stack (Q7). You expand it over time as you wire new tools in. `/audit` checks it for coverage and freshness.

| # | Layer in the stack | Tool | Mechanism | Status |
|---|---|---|---|---|
| 1 | Resolved record (the foundation) | (Nous, or your CRM) | not yet connected | not yet connected |
| 2 | CRM | (e.g. HubSpot, Salesforce, Attio) | not yet connected | not yet connected |
| 3 | Email sender | (e.g. Instantly, Smartlead, Lemlist) | not yet connected | not yet connected |
| 4 | LinkedIn tooling | (e.g. HeyReach, your own) | not yet connected | not yet connected |
| 5 | Enrichment | (e.g. Apollo, Clay) | not yet connected | not yet connected |
| 6 | Notetaker / meeting intel | (e.g. Fireflies, Granola) | not yet connected | not yet connected |
| 7 | Comms | (e.g. Slack, email, Discord) | not yet connected | not yet connected |
| 8 | Docs / knowledge | (e.g. Notion, Google Drive) | not yet connected | not yet connected |
| 9 | Lead store (your own) | (Supabase recommended, or Airtable / Sheets / CSV) | not yet connected | not yet connected |

**Mechanism options:** `mcp` (an MCP server), `script` (Python or Bash hitting an API), `export` (a CSV or JSON dump pipeline), `key+ref` (an API key plus a saved `references/{tool}-api.md` guide), `not yet connected`.

When you wire a new tool, save `references/{tool}-api.md` capturing its endpoints, auth, and common queries. Research it once, keep it forever.

---

## The resolved record

The most important row is the first one. The four layers of the system only hold together if one resolved record sits underneath them, holding every account fact in one place. **Nous is built to be that record.** It connects the tools below it, resolves every person and company into one record, and serves the whole account to your skills in a single call.

Resolving identity is the part that does the work. `sarah.chen@acme.com` in your CRM, `@sarah` in Slack, and `linkedin.com/in/sarahchen99` in your LinkedIn tooling are one person. Without a resolved record they are three rows, and your agent treats them as three strangers. With one, the call your notetaker captured and the reply your sender logged land on the same record, and every fact carries where it came from and how fresh it is.

To wire it in:

```
claude mcp add nous -- npx -y @opennous/mcp
npx -y @opennous/cli login
claude mcp list
```

The login opens your browser and saves the key for you. Then save the install command and auth method to `references/nous-mcp.md`. The record is the half of the system a static context file cannot hold: the files are your wiki, the record is what is happening inside your tools, resolved.

This is an option. The kit works with whatever record you already have.

---

## The lead store (row 9)

Your lead list should live somewhere you own. The recommended home is your own **Supabase Postgres**, wired in as an MCP, with the ready-made schema in `supabase/schema.sql`. It is modeled on Clay's waterfall enrichment structure (companies enriched once, people attached, a log of which provider found each email), so it is a Clay replacement you own. Every lead the find-and-enrich skills produce lands here with its ICP score and signals, in a database you own and can export any time.

To wire it in:

```
claude mcp add supabase -- npx -y @supabase/mcp-server-supabase --project-ref=<your-project-ref>
claude mcp list
```

Then run `supabase/schema.sql` in your project (SQL editor, or the MCP `apply_migration`), and save the setup to `references/supabase-mcp.md`. Full guide: `supabase/README.md`.

Record which store is configured here so the skills (`lookalike-builder`, `company-people`, `signal-scan`, `content-scan`) know where to read and write. Supabase is recommended; Airtable, Google Sheets, or a CSV in `leads/` also work. This is the list you work, distinct from the resolved record above, which resolves every account and interaction.
