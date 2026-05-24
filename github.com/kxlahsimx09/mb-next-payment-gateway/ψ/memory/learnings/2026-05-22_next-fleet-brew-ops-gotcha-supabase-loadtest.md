---
title: #next #fleet #brew-ops #gotcha #supabase #loadtest — Provisioning a FRESH hosted
tags: [supabase, hosted-provisioning, loadtest, fleet-secrets, brew-ops, gotcha, next]
created: 2026-05-22
source: Oracle Learn
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# #next #fleet #brew-ops #gotcha #supabase #loadtest — Provisioning a FRESH hosted

#next #fleet #brew-ops #gotcha #supabase #loadtest — Provisioning a FRESH hosted Supabase project from the mb-next-payment-gateway canonical `supabase/migrations` chain: two traps found 2026-05-22 (thread #216, dedicated loadtest project xxnhfvkchfpoomdxixmr).

1) **Verify DB-pooler auth BEFORE `supabase db push`.** The fleet-secrets `SUPABASE_DB_PASSWORD` can be wrong/stale and silently blocks the entire run — not just `db push` and the psql seed, but ALSO next-impl's G-L5 pool-probe sampler (it reads `pg_stat_activity` over a direct Bun.SQL/pooler connection). Decisive test = raw `PGPASSWORD=… psql -h <ref>.pooler.supabase.com -p 6543 -U postgres.<ref> -d postgres -tAc 'select 1'`. Raw PGPASSWORD never URL-parses, so if it fails with `28P01` the password value is genuinely wrong (not a quoting artifact). New projects' direct host `db.<ref>.supabase.co` is IPv6-only → unreachable on an IPv4 host, so the pooler (ap-southeast-1, transaction :6543 / session :5432) is the only path. The DB password "cannot be reconstructed from any API" (§3b) — only the user can re-enter it (Dashboard → Settings → Database) or you reset it via the Management API (PAT-authed) with explicit authorization. ⚠ A `#` in the password must be percent-encoded `%23` in the POOLER_URL (URL) form but stays raw in the standalone `SUPABASE_DB_PASSWORD`.

2) **Migration `20260510000012_app_settings.sql` HARD-CODES the OLD shared project** `spdazjbmyagekwxixfct` for three rows: `dispatch_callback_url`, `fair_router_url`, and `service_role_key`. After `db push` to ANY fresh/different project these point at the shared project — left uncorrected, the dispatch-callback + fair-router pg_net triggers/cron cross-fire into the shared project (exactly the disruption a dedicated project exists to avoid). MUST override all three to the new ref + new service-role JWT post-push, BEFORE calling `reset_runtime_state` (which derives `merchant_config.callback_url = replace(dispatch_callback_url,'/dispatch-callback','/mock-merchant')` — the self-contained hosted-mock loop). The access token / `supabase functions deploy --no-verify-jwt` path is unaffected by the DB-password issue (Management-API authed). Only custom EF secret actually needed = `BOT_SECRET` (+ `MERCHANT_BEHAVIOR=always_200` for a clean baseline); `INTERNAL_INVOKE_SECRET` is only a comment in fair-router, not checked.

---
*Added via Oracle Learn*
