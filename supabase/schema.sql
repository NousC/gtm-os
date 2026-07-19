-- gtm-os lead database
-- ====================
-- Your own lead database, in your own Supabase Postgres. Inspired by Clay's waterfall
-- enrichment structure, so you can replace Clay with a database you own and export.
--
-- The Clay principle in shape (the structure is the point, not the column count):
--
--   companies          firmographics, enriched ONCE per company, not per contact.
--   leads              people, each pointing at a company, with per-field provenance on
--                      the high-value fields (email, phone): which provider found it, when,
--                      verified by whom. This is what makes the data trustworthy.
--   enrichment_events  the waterfall log: one row every time a provider is called, so you
--                      can see which provider won, compare hit rates, and track cost.
--   lead_lists         a list or campaign (grouping), scoped per client for agencies.
--
-- Run once in your Supabase project (SQL Editor, or the Supabase MCP `apply_migration`).
-- Safe to re-run: fresh installs get the full shape, older flat installs get the new
-- tables and columns added without touching existing data.

create extension if not exists pgcrypto;

-- ─────────────────────────────────────────────────────────────────────────────
-- Lists / campaigns.
-- ─────────────────────────────────────────────────────────────────────────────
create table if not exists lead_lists (
  id          uuid primary key default gen_random_uuid(),
  name        text not null,
  source      text not null default 'manual',   -- lookalike | company_people | apollo | csv | manual
  client      text,                             -- agencies: the client slug this list belongs to (null = your own)
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);
create index if not exists lead_lists_created on lead_lists(created_at desc);

-- ─────────────────────────────────────────────────────────────────────────────
-- Companies: firmographics enriched once, shared across all the company's people.
-- ─────────────────────────────────────────────────────────────────────────────
create table if not exists companies (
  id            uuid primary key default gen_random_uuid(),
  name          text,
  domain        text,
  linkedin_url  text,
  description   text,

  -- Firmographics (what the ICP scores on)
  industry        text,
  sub_industry    text,
  employee_count  int,
  employee_range  text,            -- '1-10' | '11-50' | ...
  revenue_range   text,
  funding_stage   text,            -- pre-seed | seed | series_a | ...
  total_funding   text,
  last_funding_at date,
  founded_year    int,
  hq_city         text,
  hq_country      text,

  -- Rich enrichment (from AI-Ark, signal-scan, and the web)
  tech_stack    jsonb not null default '[]',   -- ['clay','smartlead','hubspot']
  job_openings  jsonb not null default '[]',
  signals       jsonb not null default '{}',   -- { stack:{...}, hiring:{...}, momentum:{...}, friction:{...}, domain:{...} }

  -- The ICP score, company-level fit (from Nous, or signal-scan)
  icp_score     int,               -- 0..100
  icp_reason    text,
  keywords      jsonb not null default '[]',   -- the GTM terms on their site (powers keyword scoring)

  -- Firmographics are objective and shared, so a company exists once per domain. Per-client
  -- ICP scores live on the leads (leads.icp_score), scored against that client's model.
  enriched_at   timestamptz,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now()
);
create index if not exists companies_score on companies(icp_score desc nulls last);
-- One company per domain. Nulls stay distinct, so company rows with no domain are allowed.
create unique index if not exists companies_domain_uniq on companies(lower(domain));

-- ─────────────────────────────────────────────────────────────────────────────
-- Leads (people): each points at a company. Provenance on the fields that must be trusted.
-- ─────────────────────────────────────────────────────────────────────────────
create table if not exists leads (
  id            uuid primary key default gen_random_uuid(),
  lead_list_id  uuid references lead_lists(id) on delete cascade,
  company_id    uuid references companies(id)  on delete set null,

  -- Identity
  name          text,
  first_name    text,
  last_name     text,
  email         text,
  email_status  text,            -- verified | risky | invalid | unknown | catchall
  linkedin_url  text,
  title         text,
  seniority     text,            -- founder | c_level | vp | director | manager | ic
  department    text,

  -- Extra contact channels
  personal_email text,
  mobile_phone   text,
  direct_phone   text,
  twitter_handle text,
  city           text,
  country        text,

  -- Provenance on the high-value fields (this is what makes the waterfall real)
  email_source      text,        -- which provider found the work email (prospeo|apollo|neverbounce|linkedin_scrape|...)
  email_verified_at timestamptz,
  email_verified_by text,        -- who verified it (neverbounce|bounceban|...)
  phone_source      text,
  phone_found_at    timestamptz,

  -- Enrichment bookkeeping
  last_verified_at  timestamptz, -- for the re-verify freshness loop
  enriched_at       timestamptz,
  enriched_by       text,
  credits_spent     numeric not null default 0,

  -- Person-level enrichment (intent from their own posts)
  signals       jsonb not null default '{}',   -- { intent:{ detected, score, angle, anchor_post } }

  -- Person-level score (optional; the displayed score falls back to the company's fit)
  icp_score     int,
  icp_reason    text,

  -- Workflow
  tags          text[] not null default '{}',
  status        text not null default 'new',   -- new | qualified | queued | sent | replied | dropped
  source        text,            -- where the lead came from (stamp it, so reply rates compare)
  client        text,            -- agencies: scope the lead to a client
  notes         text,

  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now()
);
create index if not exists leads_list    on leads(lead_list_id, created_at desc);
create index if not exists leads_company  on leads(company_id);
create index if not exists leads_email    on leads(lower(email))  where email is not null;
create index if not exists leads_status   on leads(status);
create index if not exists leads_client   on leads(client) where client is not null;
create index if not exists leads_stale    on leads(last_verified_at) where email is not null;
-- One lead per email per list. A partial unique INDEX (an expression like lower(email)
-- is not allowed in a table-level unique constraint), skipping email-less company rows.
create unique index if not exists leads_list_email_uniq
  on leads(lead_list_id, lower(email)) where email is not null;

-- ─────────────────────────────────────────────────────────────────────────────
-- The waterfall log: one row every time a provider is called. This is the table that
-- turns "a lead list" into "a Clay replacement". It records which provider won, what the
-- others returned, and the cost, so you can compare hit rates and prove provenance.
-- ─────────────────────────────────────────────────────────────────────────────
create table if not exists enrichment_events (
  id           uuid primary key default gen_random_uuid(),
  lead_id      uuid references leads(id)     on delete cascade,
  company_id   uuid references companies(id) on delete cascade,
  field        text not null,   -- work_email | phone | mobile | company | linkedin | ...
  provider     text not null,   -- prospeo | dropcontact | hunter | apollo | datagma | neverbounce | harvestapi | aiark | ...
  status       text not null,   -- hit | miss | risky | verified | invalid
  value_found  text,            -- the value the provider returned (nullable on a miss)
  credits      numeric not null default 0,
  ran_at       timestamptz not null default now()
);
create index if not exists enrichment_lead    on enrichment_events(lead_id, ran_at desc);
create index if not exists enrichment_company on enrichment_events(company_id, ran_at desc);
create index if not exists enrichment_provider on enrichment_events(field, provider, status);

-- ─────────────────────────────────────────────────────────────────────────────
-- Upgrade path: older flat installs (one leads table, no companies) get the new columns
-- and tables added without losing data. Safe to re-run. Fresh installs skip all of these.
-- ─────────────────────────────────────────────────────────────────────────────
alter table lead_lists add column if not exists client text;
alter table leads add column if not exists company_id uuid references companies(id) on delete set null;
alter table leads add column if not exists first_name text;
alter table leads add column if not exists last_name text;
alter table leads add column if not exists seniority text;
alter table leads add column if not exists department text;
alter table leads add column if not exists personal_email text;
alter table leads add column if not exists mobile_phone text;
alter table leads add column if not exists direct_phone text;
alter table leads add column if not exists twitter_handle text;
alter table leads add column if not exists city text;
alter table leads add column if not exists country text;
alter table leads add column if not exists email_source text;
alter table leads add column if not exists email_verified_at timestamptz;
alter table leads add column if not exists email_verified_by text;
alter table leads add column if not exists phone_source text;
alter table leads add column if not exists phone_found_at timestamptz;
alter table leads add column if not exists last_verified_at timestamptz;
alter table leads add column if not exists enriched_at timestamptz;
alter table leads add column if not exists enriched_by text;
alter table leads add column if not exists credits_spent numeric not null default 0;
alter table leads add column if not exists client text;

-- ─────────────────────────────────────────────────────────────────────────────
-- updated_at maintenance.
-- ─────────────────────────────────────────────────────────────────────────────
create or replace function set_updated_at() returns trigger as $$
begin new.updated_at = now(); return new; end;
$$ language plpgsql;

drop trigger if exists lead_lists_updated_at on lead_lists;
create trigger lead_lists_updated_at before update on lead_lists
  for each row execute function set_updated_at();

drop trigger if exists companies_updated_at on companies;
create trigger companies_updated_at before update on companies
  for each row execute function set_updated_at();

drop trigger if exists leads_updated_at on leads;
create trigger leads_updated_at before update on leads
  for each row execute function set_updated_at();

-- ─────────────────────────────────────────────────────────────────────────────
-- The spreadsheet view: one row per lead, the company firmographics and the ICP score
-- joined on, best-fit first. This is what you read (and render as a table) to work the list.
-- The score shown is the person's own if set, otherwise the company's fit.
-- ─────────────────────────────────────────────────────────────────────────────
create or replace view lead_rows as
select
  l.id,
  l.client                              as client,
  ll.name                               as list,
  -- person
  l.name, l.title, l.seniority, l.email, l.email_status, l.email_source,
  l.linkedin_url, l.last_verified_at,
  -- company
  c.name        as company,
  c.domain,
  c.industry,
  c.employee_count,
  c.employee_range,
  c.funding_stage,
  -- the score (person over company)
  coalesce(l.icp_score, c.icp_score)    as icp_score,
  coalesce(l.icp_reason, c.icp_reason)  as icp_reason,
  -- signals: company (shared) + this person's intent
  c.signals                             as company_signals,
  l.signals                             as person_signals,
  -- workflow
  l.status, l.tags, l.source, l.credits_spent,
  l.created_at
from leads l
left join companies  c  on c.id  = l.company_id
left join lead_lists ll on ll.id = l.lead_list_id
order by coalesce(l.icp_score, c.icp_score) desc nulls last, l.created_at desc;
