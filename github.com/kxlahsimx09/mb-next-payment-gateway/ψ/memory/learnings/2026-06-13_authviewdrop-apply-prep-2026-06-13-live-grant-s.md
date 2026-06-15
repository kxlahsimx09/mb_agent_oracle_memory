---
title: authviewdrop APPLY-PREP (2026-06-13): live grant sweep proves D1 (surgical 2-tab
tags: [brew-ops, repo:mb-next-payment-gateway, supabase, security, investigator-ro, auth, grant-sweep, keep, deny-by-default, bot-credentials, pg-stat-statements]
created: 2026-06-13
source: brew-ops authviewdrop APPLY-PREP, thread #16 msg 422, 2026-06-13
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# authviewdrop APPLY-PREP (2026-06-13): live grant sweep proves D1 (surgical 2-tab

authviewdrop APPLY-PREP (2026-06-13): live grant sweep proves D1 (surgical 2-table revoke) is INCOMPLETE — investigator_ro can read more secret-bearing tables on sinuw than the architect's in-repo sweep found. Recommend D2 (deny-by-default).

Tags: #brew-ops #repo:mb-next-payment-gateway #supabase #security #investigator-ro #auth #grant-sweep #keep #p-004

**Context:** PR #486 (1e2afb0) added migration `20260613000020` (secret-free auth.* forensic views, owner-context security_invoker=false + column-allowlist) and `20260613000030` (D1: REVOKE investigator_ro SELECT on merchant_config+client, GRANT secret-free projections). The 30 migration is owner-gated "DO NOT APPLY AT MERGE". brew-ops ran 4 read-only preflight checks on live sinuw.

**investigator_ro is BROAD: 44 public tables SELECT (live-provisioned, NOT in repo).** Live sweep — secret-bearing columns it can read beyond D1's merchant_config.secret + client.api_key/api_key_secret:
- **bot_credentials** — `secret_enc` (bytea, encrypted bot secret §ADR-7) + `bot_key`. REAL credential. D1 misses it.
- **client_callback_endpoints.endpoint_key**, **ts_deposits/ts_payouts/v_deposits.callback_endpoint_key** — likely callback signing keys (classify).
- **app_settings** — `(key,value)` text kv; `value` may hold secrets (column-NAME regex misses it; audit the rows).
- benign (name-matched only): callback_queue.dedup_key, idempotency_keys.key, app_settings.key.
⇒ D1 enumerate-and-revoke is whack-a-mole + proven incomplete; grants are live-provisioned so the next secret table re-leaks silently. **Recommend D2: REVOKE ALL public from investigator_ro + GRANT an explicit secret-free allowlist** (auth views + forensic projections covering bot_credentials/callback-key family/audited app_settings). next-architect's durable RO-surface slice should scope to this full list.

**Keep uses investigator_ro:** keep.env = "CANONICAL sinuw … investigator_ro scoped-read via pooler". The §ADR-15 monitoring reads sinuw AS investigator_ro → any REVOKE has Keep blast-radius. BUT for the D1 targets it's safe: 0 of 2701 `pg_stat_statements` reference merchant_config or the client base table (monitoring design doesn't either). A D2 REVOKE-ALL would need the Keep read-surface in the allowlist first.

**auth-views preflight (migration 20) = GO:** postgres holds SELECT on all 4 auth.* (views are owner-context → won't fail closed); every INCLUDE col exists live (views create); secret-free. The column-ALLOWLIST design correctly auto-excludes NEW secret columns the migration's prose comments don't mention — notably **`auth.sessions.refresh_token_hmac_key`** (a real secret; the migration comment "no secret columns on this table" is now stale) and `auth.mfa_factors.last_webauthn_challenge_data`. Validates allowlist > denylist for auth bridges.

---
*Added via Oracle Learn*
