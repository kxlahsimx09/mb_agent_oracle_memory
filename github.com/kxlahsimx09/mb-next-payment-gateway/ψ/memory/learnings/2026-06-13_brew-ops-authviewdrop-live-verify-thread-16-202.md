---
title: brew-ops authviewdrop live-verify (thread #16, 2026-06-13) — v_auth_* DROP confi
tags: [brew-ops, repo:mb-next-payment-gateway, next, auth, security, rls, investigator-ro, gotcha, finding, verification]
created: 2026-06-13
source: thread #16 authviewdrop 2026-06-13; live psql as investigator_ro on sinuw + Management API on qnccph
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# brew-ops authviewdrop live-verify (thread #16, 2026-06-13) — v_auth_* DROP confi

brew-ops authviewdrop live-verify (thread #16, 2026-06-13) — v_auth_* DROP confirmed; investigator_ro still reads a BUSINESS secret via its broad public-table grant.

## What was verified (read-only, as investigator_ro on sinuw + postgres on qnccph)
The four hand-rolled `public.v_auth_*` SELECT* bridge views (which had dragged `auth.mfa_factors.secret` plaintext TOTP seed, `auth.users.encrypted_password`, and `*_token` across the auth trust boundary to `investigator_ro`) are GONE:
- sinuw (AS investigator_ro): 0 `v_auth_*` public views; `public.v_auth_mfa_factors.secret` / `public.v_auth_users.encrypted_password` → 42P01 (relation absent); `auth.mfa_factors.secret` / `auth.users.encrypted_password` / `auth.users.{confirmation_token,recovery_token}` → 42501 permission denied for schema auth. Auth crypto boundary CLOSED.
- qnccph (postgres/Mgmt-API): 0 `v_auth_*` views; `investigator_ro` role does NOT exist there — it is a **sinuw-only** role.
- dev-2: unprovisioned placeholder (`SUPABASE_URL=REPLACE_ME`; no `mb-next-dev2` project exists) → no stack, no leak.

## Method note (reusable)
To test "as investigator_ro" use the RO connection in `investigator.env` → `SINUW_RO_DB_URL` (= `postgresql://investigator_ro.sinuwgsqqyqzlpaavimf:***@aws-1-ap-southeast-1.pooler.supabase.com:5432/postgres`). The Management API `database/query` runs as **postgres** (sees everything) so it CANNOT test a non-owner's deny — only a real `investigator_ro` psql connection proves the 42501/42P01. The thorough sweep: `select ... from pg_attribute a join pg_class c ... where (a.attname in ('secret','encrypted_password') or a.attname ilike '%token%') and has_table_privilege('investigator_ro', c.oid,'SELECT')` (cast `relkind::text`).

## ADJACENT FINDING (open — architect/owner disposition)
That sweep shows `investigator_ro` can still SELECT **`public.merchant_config.secret`** (a merchant callback/signing secret; `has_table_privilege=true`, 1 non-null row) — via its BROAD public-table SELECT grant for §ADR-21 L3 ground-truth reads. NOT an `auth.*` leak, but the ratified rule ("`secret`/`encrypted_password`/`*_token` must never be readable by a non-owner") literally covers it. So the durable secret-free investigator-RO surface (authviewdrop Part 2) must exclude/column-mask **business** secrets too, not only auth — i.e. column-explicit projections, not table-level SELECT on raw public business tables. (Benign sweep noise: `pg_catalog.pg_ts_config_map.maptokentype`, `pg_catalog.pg_ts_parser.prstoken` — system text-search catalogs, world-readable.)

---
*Added via Oracle Learn*
