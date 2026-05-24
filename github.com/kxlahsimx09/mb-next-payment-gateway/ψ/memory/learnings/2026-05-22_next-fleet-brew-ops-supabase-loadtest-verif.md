---
title: #next #fleet #brew-ops #supabase #loadtest — VERIFIED hosted-provisioning recipe
tags: [supabase, hosted-provisioning, loadtest, pooler, password-reset, matcher, brew-ops, next]
created: 2026-05-22
source: Oracle Learn
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# #next #fleet #brew-ops #supabase #loadtest — VERIFIED hosted-provisioning recipe

#next #fleet #brew-ops #supabase #loadtest — VERIFIED hosted-provisioning recipe (2026-05-22, thread #216, project xxnhfvkchfpoomdxixmr provisioned end-to-end + smoke-green). Complements [[2026-05-22_next-fleet-brew-ops-gotcha-supabase-loadtest]].

**DB password reset (when fleet-secrets pw is wrong + user authorizes rotation):** `PATCH https://api.supabase.com/v1/projects/{ref}/database/password` body `{"password":"<hex>"}`, PAT-authed — WORKS. `ALTER USER postgres WITH PASSWORD` via the SQL query endpoint does NOT (Supabase `postgres` is not a real superuser; `supabase_admin` is, and is unreachable). Generate the new password URL-SAFE (e.g. `openssl rand -hex 18`) so the standalone `SUPABASE_DB_PASSWORD` and the `SUPABASE_DB_POOLER_URL`-embedded form are identical (no `#`/`%23` dual-encoding). Guard the fleet-secrets write on a live auth probe so a failed reset never overwrites a good value — but guard on the SESSION pooler `:5432` (not tx `:6543`): after a reset, `:6543` lags `:5432` by seconds picking up the new SCRAM verifier, so a `:6543`-only guard fails spuriously AND loses the just-set password.

**Connection paths (new project):** direct host `db.<ref>.supabase.co` is IPv6-only → unreachable on an IPv4 host. Use poolers: `supabase db push --db-url <session-pooler :5432>` (migrations need session mode; tx `:6543` breaks them); apps + the G-L5 `pg_stat_activity` sampler use tx `:6543` (the stored POOLER_URL). `supabase functions deploy --no-verify-jwt --project-ref <ref>` + `supabase secrets set` are PAT-authed (no DB password).

**The full canonical chain pushes clean to a fresh project** — 105 migrations incl. the `run_hosted_assertions` + `*_assertions` migrations all PASS on a fresh apply (the src↔migration drift-guard the load-test plan wanted). app_settings (`dispatch_callback_url`/`fair_router_url`/`service_role_key`) must be overridden to the new ref BEFORE `reset_runtime_state` (which derives `merchant_config.callback_url → …/mock-merchant`, the self-contained hosted-mock loop). 13-bank seed = `77777777-…-001..013` in main_pool `66666666…001`, deposit+payout on all.

**Matcher gotcha (for any manual create→match smoke):** `match_deposits_cascade` Step-1 is SOURCE-IDENTITY-scoped (§ADR-4b A3) — a same-bank + same-amount + in-window statement does NOT match unless the statement's `source_account_no` aligns with the deposit's `customer_bank_account_number` (full match → `_extract_source_identity_v2` score 2; last-4 → score 1). So a hand-crafted smoke must create the deposit with `customer_bank_account_number=X` and submit the statement with `source_account_no=X`. The integration fixture handles this automatically.

---
*Added via Oracle Learn*
