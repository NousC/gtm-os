# Connections

Registry of every tool this OS can reach. This is your System of Integration. `/onboard` fills it from your stack (Q7). You expand it over time as you wire new tools in. `/audit` checks it for coverage and freshness.

| # | Layer in the stack | Tool | Mechanism | Status |
|---|---|---|---|---|
| 1 | Resolved record (the foundation) | (Nous, or your CRM) | mcp / not yet connected |: |
| 2 | CRM | (e.g. HubSpot, Salesforce, Attio) |: | not yet connected |
| 3 | Email sender | (e.g. Instantly, Smartlead, Lemlist) |: | not yet connected |
| 4 | LinkedIn tooling | (e.g. HeyReach, your own) |: | not yet connected |
| 5 | Enrichment | (e.g. Apollo, Clay) |: | not yet connected |
| 6 | Notetaker / meeting intel | (e.g. Fireflies, Granola) |: | not yet connected |
| 7 | Comms | (e.g. Slack, email, Discord) |: | not yet connected |
| 8 | Docs / knowledge | (e.g. Notion, Google Drive) |: | not yet connected |

**Mechanism options:** `mcp` (an MCP server), `script` (Python or Bash hitting an API), `export` (a CSV or JSON dump pipeline), `key+ref` (an API key plus a saved `references/{tool}-api.md` guide), `not yet connected`.

When you wire a new tool, save `references/{tool}-api.md` capturing its endpoints, auth, and common queries. Research it once, keep it forever.

---

## The resolved record

The most important row is the first one. The four layers of the system only hold together if one resolved record sits underneath them, holding every account fact in one place. **Nous is built to be that record.** It connects the tools below it, resolves every person and company into one record, and serves the whole account to your skills in a single call.

To wire it in:

```
claude mcp add nous <command-or-url>
claude mcp list
```

Then save the install command and auth method to `references/nous-mcp.md`. Wiring the resolved record first means your CRM, your email, and your meeting notes all surface through one account view instead of staying split across tools.

This is an option, not a requirement. The kit works with whatever record you already have.
