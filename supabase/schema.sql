-- gtm-os lead store
-- =================
-- A lead list you own, in your own Supabase Postgres. This is the alternative to
-- keeping leads locked inside a vendor tool: it is your database, your rows, your export.
--
-- Adapted from the Nous leads schema, simplified and made self-contained (no workspace
-- or contacts tables, no RLS assumptions). Run it once in your Supabase project (SQL
-- Editor, or via the Supabase MCP `apply_migration`). Safe to re-run.
--
-- What it holds:
--   lead_lists  one row per list or campaign
--   leads       one row per lead: identity + firmographics + ICP score + signals + tags
--   lead_list_overview  a view: the working list, best-fit first
--
-- How it fills up:
--   lookalike-builder  writes the companies it discovers
--   company-people     writes the decision-maker + verified email at each company
--   signal-scan        writes the six signal classes + the ICP score onto each lead
--   content-scan       writes the LinkedIn intent signal onto each lead
--   Nous (optional)    computes the ICP score and pushes it into leads.icp_score

create extension if not exists pgcrypto;

-- One row per list or campaign.
create table if not exists lead_lists (
  id          uuid primary key default gen_random_uuid(),
  name        text not null,
  source      text not null default 'manual',   -- lookalike | company_people | apollo | csv | manual
  client      text,                             -- agencies: the client slug this list belongs to (null = your own)
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

create index if not exists lead_lists_created on lead_lists(created_at desc);

-- One row per lead.
create table if not exists leads (
  id            uuid primary key default gen_random_uuid(),
  lead_list_id  uuid references lead_lists(id) on delete cascade,

  -- Identity
  name          text,
  email         text,
  email_status  text,            -- verified | risky | invalid | unknown
  company       text,
  domain        text,
  linkedin_url  text,
  title         text,

  -- Firmographics (what the ICP scores on)
  industry        text,
  employee_count  int,

  -- The ICP score (pushed from Nous, or set by a scoring skill)
  icp_score     int,             -- 0..100
  icp_reason    text,

  -- Enrichment from signal-scan / content-scan
  signals       jsonb not null default '{}',   -- { stack:{...}, hiring:{...}, momentum:{...}, intent:{...} }
  signal_brief  text,            -- the copy-fuel brief (markdown), from signal-scan

  -- Workflow
  tags          text[] not null default '{}',
  status        text not null default 'new',   -- new | qualified | queued | sent | replied | dropped
  source        text,            -- where the lead came from (stamp it, so reply rates compare)
  client        text,            -- agencies: the client slug this lead belongs to (null = your own)
  notes         text,

  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now()
);

create index if not exists leads_list   on leads(lead_list_id, created_at desc);
create index if not exists leads_email  on leads(lower(email))  where email  is not null;
create index if not exists leads_domain on leads(lower(domain)) where domain is not null;
create index if not exists leads_score  on leads(icp_score desc nulls last);
create index if not exists leads_status on leads(status);
create index if not exists leads_client on leads(client) where client is not null;

-- One lead per email per list. A partial unique INDEX, not a table-level unique (...),
-- because Postgres does not allow an expression like lower(email) in a table constraint.
-- lower(email) is the point (Bob@x.com == bob@x.com); the partial where keeps email-less
-- company rows out of the index.
create unique index if not exists leads_list_email_uniq
  on leads(lead_list_id, lower(email))
  where email is not null;

-- Upgrade path: if you created the store before the client column existed, these add it
-- without touching your data. Safe to re-run.
alter table lead_lists add column if not exists client text;
alter table leads      add column if not exists client text;

-- updated_at maintenance.
create or replace function set_updated_at() returns trigger as $$
begin new.updated_at = now(); return new; end;
$$ language plpgsql;

drop trigger if exists lead_lists_updated_at on lead_lists;
create trigger lead_lists_updated_at before update on lead_lists
  for each row execute function set_updated_at();

drop trigger if exists leads_updated_at on leads;
create trigger leads_updated_at before update on leads
  for each row execute function set_updated_at();

-- The working list, best-fit first. Read this to see your pipeline.
create or replace view lead_list_overview as
select
  l.id,
  coalesce(l.client, ll.client) as client,
  ll.name        as list,
  l.name,
  l.title,
  l.company,
  l.domain,
  l.email,
  l.email_status,
  l.icp_score,
  l.status,
  l.tags,
  l.signals,
  l.created_at
from leads l
join lead_lists ll on ll.id = l.lead_list_id
order by l.icp_score desc nulls last, l.created_at desc;
