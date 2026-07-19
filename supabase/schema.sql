-- gtm-os lead store, v2 (Clay-shaped)
-- =====================================
-- Upgrades the flat v1 `leads` table into a real, agency-grade lead store:
--   companies         one row per company (firmographics, funding, tech, ICP)
--   leads             one row per person, FK to companies, + per-field provenance
--   lead_emails       the candidate emails per person, one marked primary (v2.1)
--   enrichment_events the waterfall log: one row per provider call
--   lead_list_overview a view joining people to companies, best-fit first
--
-- Safe to run on a fresh project. To migrate an existing v1 store, run the
-- "MIGRATE FROM v1" block at the bottom instead of the plain table creates.
-- Apply via the Supabase MCP `apply_migration`, or the SQL editor.

create extension if not exists pgcrypto;

-- ── Lists ────────────────────────────────────────────────────────────────
create table if not exists lead_lists (
  id          uuid primary key default gen_random_uuid(),
  name        text not null,
  source      text not null default 'manual',   -- lookalike | company_people | apollo | csv | manual
  client      text,                             -- agencies: the client slug this list belongs to
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);
create index if not exists lead_lists_created on lead_lists(created_at desc);

-- ── Companies (firmographics live here once) ─────────────────────────────
create table if not exists companies (
  id             uuid primary key default gen_random_uuid(),
  name           text not null,
  domain         text unique,
  linkedin_url   text,
  description    text,
  industry       text,
  sub_industry   text,
  employee_count int,
  employee_range text,               -- 1-10 | 11-50 | 51-200 | 201-500 | 500+
  revenue_range  text,
  funding_stage  text,               -- bootstrapped | Seed | Series A | ...
  total_funding  numeric,
  last_funding_at date,
  founded_year   int,
  hq_city        text,
  hq_country     text,
  tech_stack     jsonb not null default '{}',   -- { crm, esp, platform, ... }
  job_openings   jsonb not null default '{}',   -- { count, roles[] }
  signals        jsonb not null default '{}',   -- stack/hiring/momentum/friction/domain
  icp_score      int,                -- account-level fit
  icp_reason     text,
  client         text,
  enriched_at    timestamptz,
  enriched_by    text,
  created_at     timestamptz not null default now(),
  updated_at     timestamptz not null default now()
);
create index if not exists companies_domain on companies(lower(domain));
create index if not exists companies_score  on companies(icp_score desc nulls last);
create index if not exists companies_client on companies(client) where client is not null;

-- ── Leads (people) ───────────────────────────────────────────────────────
create table if not exists leads (
  id            uuid primary key default gen_random_uuid(),
  lead_list_id  uuid references lead_lists(id) on delete cascade,
  company_id    uuid references companies(id) on delete set null,

  -- Identity
  name          text,
  title         text,
  seniority     text,
  department    text,
  linkedin_url  text,
  city          text,
  country       text,

  -- The chosen (primary) work email, a convenience mirror of the primary lead_emails row
  email         text,
  email_status  text,            -- verified | risky | invalid | unknown
  email_source  text,            -- provider that won the waterfall
  email_verified_at timestamptz,
  email_verified_by text,        -- the verifier (NeverBounce / ZeroBounce)

  -- Other contact
  personal_email text,
  mobile_phone   text,
  direct_phone   text,
  phone_source   text,
  phone_found_at timestamptz,
  twitter_handle text,

  -- Enrichment / person-level signals
  signals       jsonb not null default '{}',   -- person-level, e.g. { intent: {...} }
  signal_brief  text,
  icp_score     int,             -- person-level score (inherits company + own intent)
  icp_reason    text,

  -- Freshness + cost
  last_verified_at timestamptz,
  enriched_at   timestamptz,
  enriched_by   text,
  credits_spent numeric not null default 0,

  -- Workflow
  tags          text[] not null default '{}',
  status        text not null default 'new',   -- new | qualified | queued | sent | replied | dropped
  source        text,
  client        text,
  notes         text,

  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now()
);
create index if not exists leads_list   on leads(lead_list_id, created_at desc);
create index if not exists leads_company on leads(company_id);
create index if not exists leads_email   on leads(lower(email))  where email  is not null;
create index if not exists leads_score   on leads(icp_score desc nulls last);
create index if not exists leads_status  on leads(status);
create index if not exists leads_client  on leads(client) where client is not null;
create unique index if not exists leads_list_email_uniq on leads(lead_list_id, lower(email)) where email is not null;

-- ── Candidate emails (v2.1, the Clay work-email model) ──────────────────
-- One row per email a provider returned for a person. The waterfall verifies each
-- and marks the first verified-deliverable one is_primary; that one mirrors to leads.email.
create table if not exists lead_emails (
  id           uuid primary key default gen_random_uuid(),
  lead_id      uuid references leads(id) on delete cascade,
  email        text not null,
  kind         text not null default 'work',   -- work | personal
  provider     text,                            -- who returned this candidate
  verification text,                            -- verified | risky | invalid | catch_all | unchecked
  is_primary   boolean not null default false,  -- the chosen work email
  found_at     timestamptz not null default now()
);
create index if not exists lead_emails_lead on lead_emails(lead_id);
create unique index if not exists lead_emails_uniq on lead_emails(lead_id, lower(email));
create unique index if not exists lead_emails_one_primary on lead_emails(lead_id) where is_primary;

-- ── Enrichment events (the waterfall log) ────────────────────────────────
create table if not exists enrichment_events (
  id          uuid primary key default gen_random_uuid(),
  lead_id     uuid references leads(id) on delete cascade,
  company_id  uuid references companies(id) on delete cascade,
  field       text not null,   -- work_email | personal_email | mobile_phone | firmographics | linkedin | intent
  provider    text not null,   -- prospeo | dropcontact | apollo | hunter | findymail | neverbounce | contactout | ai-ark ...
  status      text not null,   -- hit | miss | risky | verified | invalid | error
  value_found text,
  credits     numeric not null default 0,
  ran_at      timestamptz not null default now()
);
create index if not exists enrich_lead     on enrichment_events(lead_id, ran_at desc);
create index if not exists enrich_company  on enrichment_events(company_id, ran_at desc);
create index if not exists enrich_provider on enrichment_events(provider);
create index if not exists enrich_field    on enrichment_events(field);

-- ── updated_at maintenance ───────────────────────────────────────────────
create or replace function set_updated_at() returns trigger as $$
begin new.updated_at = now(); return new; end;
$$ language plpgsql;
drop trigger if exists lead_lists_updated_at on lead_lists;
create trigger lead_lists_updated_at before update on lead_lists for each row execute function set_updated_at();
drop trigger if exists companies_updated_at on companies;
create trigger companies_updated_at before update on companies for each row execute function set_updated_at();
drop trigger if exists leads_updated_at on leads;
create trigger leads_updated_at before update on leads for each row execute function set_updated_at();

-- ── The working view: people joined to their company, best-fit first ─────
drop view if exists lead_list_overview;
create view lead_list_overview as
select
  l.id,
  coalesce(l.client, ll.client, c.client) as client,
  ll.name              as list,
  l.name, l.title, l.seniority,
  c.name               as company,
  c.domain, c.industry, c.employee_count, c.employee_range, c.revenue_range, c.funding_stage,
  l.email, l.email_status, l.email_source, l.last_verified_at, l.mobile_phone,
  l.icp_score, l.status, l.tags, l.signals, c.signals as company_signals,
  l.created_at
from leads l
join lead_lists ll on ll.id = l.lead_list_id
left join companies c on c.id = l.company_id
order by l.icp_score desc nulls last, l.created_at desc;

-- ── RLS (writes go through the privileged MCP connection, which bypasses RLS) ─
alter table lead_lists        enable row level security;
alter table companies         enable row level security;
alter table leads             enable row level security;
alter table lead_emails       enable row level security;
alter table enrichment_events enable row level security;

-- ── MIGRATE FROM v1 (run only if you already had the flat v1 leads table) ─
-- 1. create companies from existing leads:
--    insert into companies (name, domain, industry, employee_count, client, signals, icp_score, icp_reason, enriched_at, enriched_by)
--    select distinct on (lower(domain)) company, domain, industry, employee_count, client, signals, icp_score, icp_reason, now(), 'migration'
--    from leads where domain is not null order by lower(domain), icp_score desc nulls last;
-- 2. link + backfill lead_emails from the single email:
--    update leads l set company_id = c.id from companies c where lower(l.domain) = lower(c.domain);
--    insert into lead_emails (lead_id, email, provider, verification, is_primary)
--    select id, email, email_source, email_status, true from leads where email is not null;
-- 3. drop the moved firmographic columns:
--    alter table leads drop column if exists industry; alter table leads drop column if exists employee_count;
