---
title: A4 split-by-verb RLS build (PR #385, migration 20260611000010) — durable substra
tags: [next-dev, repo:mb-next-payment-gateway, next, migration, rls, auth-phase2, build, gotcha]
created: 2026-06-11
source: PR https://github.com/kxlahsimx09/mb-next-payment-gateway/pull/385 @ branch fix/auth-phase2-a4-rls
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# A4 split-by-verb RLS build (PR #385, migration 20260611000010) — durable substra

A4 split-by-verb RLS build (PR #385, migration 20260611000010) — durable substrate facts:

1. **aal in RLS**: gotrue stamps `aal` as a TOP-LEVEL access-token claim (admin-auth.ts:107 "real gotrue JWTs always carry aal"; the custom access-token hook preserves incoming claims) → the m2 predicate is plain `auth.jwt()->>'aal' = 'aal2'`. pgTAP drives it via `SET LOCAL "request.jwt.claims"` with `{"sub":...,"aal":"aal2"}`.
2. **Once-per-query RLS resolvers**: wrap every helper call in a scalar subquery `(SELECT fn())` → Postgres plans it as an uncorrelated InitPlan, evaluated once per query. SECURITY DEFINER + `SET search_path` block SQL-function inlining, so the fn name stays visible in EXPLAIN — but ONLY with `EXPLAIN (VERBOSE)`: PG17 prints bare `InitPlan n -> Result` without it (cost: one failed assertion until fixed). Negative assertion: plan must NOT match `Filter:[^\n]*has_read_perm`.
3. **dev-1 drift gotcha**: dev-1 (lsgheeuhvfqhmombfqsl) was 11 migrations behind (history ended 20260528000001) — the auth-login + RLS-tenant lanes had NEVER been deployed there. Also `supabase db push` v2.104 pipeline mode cannot run `DROP/CREATE INDEX CONCURRENTLY` (migration 20260528170000): apply the file CONCURRENTLY-stripped via Management API `database/query` + manually INSERT the version into supabase_migrations.schema_migrations, then push the rest. Management API blocks python urllib (CF 1010) — use curl.
4. **pgTAP on remote stacks**: no psql on the fleet host by default → `brew install libpq`, run test files over the IPv4 session pooler. CLEAN-DB count assertions break on a shared dev stack — scope every cross-tenant admin count to fixture ids. `client` now requires `expired_deposit_seconds` NOT NULL in fixtures. Minimal `INSERT INTO auth.users (id)` works for partner_profiles FK.
5. **Seed HOLD pattern**: when a grant matrix is unratified, ship the predicate + resolver substrate with an actions-only seed + defensive `DELETE ... LIKE '%:view'`, and drive pgTAP tier behavior via TRANSACTION-LOCAL fixture grants (rolled back) — fail-closed in prod, fully testable in CI.
6. **Residual flagged to architect**: ~20 RLS-less public tables (app_user, client.api_key, merchant_config.secret, bank_account, step_up_*, …) remain SELECT-able by anon+authenticated via Supabase default grants; A4 revoked writes everywhere, the READ withdrawal list is A2/SV6-class (not dev's to invent).

---
*Added via Oracle Learn*
