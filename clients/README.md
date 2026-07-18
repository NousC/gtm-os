# clients/

If you run go-to-market for more than one company, an agency, a fractional team, a
studio, this is where each client lives. One folder per client, each with its own context
wiki, so a task for Acme reads Acme's positioning and voice, never yours or another
client's.

Solo, selling your own thing? You do not need this folder. Ignore it. Your business lives
in the root `context/` wiki and that is the whole story.

## The split

- **Root `context/`** is your own business: who your agency is, the kind of client you want
  (that is your ICP), how you talk. It is you.
- **`clients/<slug>/context/`** is one client's business: their positioning, their ICP,
  their voice, their competitors, their pricing. A full mini-wiki, the same pages as root,
  scoped to that client.

```
gtm-os/
├── context/                  your agency's own business
├── clients/
│   ├── acme/
│   │   └── context/          Acme's wiki: index.md + the 7 pages
│   └── globex/
│       └── context/          Globex's wiki
└── supabase/                 one lead store, a `client` column scopes each row
```

## How the OS uses it

- **Add a client.** Run `/onboard` and say it is for a client (name them). It runs the same
  interview, about that client's business, and scaffolds `clients/<slug>/context/` instead
  of touching root. Re-run any time to refresh one client.
- **Work a client.** When a task names a client ("signal-scan Acme's list", "draft a
  sequence for Globex"), the skills read `clients/<slug>/context/` as the lens instead of
  root `context/`. No client named means your own root context.
- **One lead store, scoped.** Leads carry a `client` value (the slug), so a single Supabase
  holds every client's pipeline and you filter to one client at a time. Want a
  client's data fully isolated instead? Point that client at its own Supabase in
  `clients/<slug>/context/` and note it there. One shared store is the default; isolation is
  a choice.

## The rule that keeps it clean

The hard split still holds, per client. Each `clients/<slug>/context/` is the wiki about
*that client's* business. The accounts and people that client targets are still "them", and
still live in the lead store and the resolved record, never in a context page. You are just
running the same system once per client, side by side.
