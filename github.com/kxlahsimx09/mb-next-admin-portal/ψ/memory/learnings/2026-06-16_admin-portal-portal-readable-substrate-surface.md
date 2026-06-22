---
title: ## admin-portal: portal-readable substrate surface + the per-EF CORS gap (2026-0
tags: [mb-next-admin-portal, next-ui, rls, rbac, cors, edge-functions, supabase, live-test, staging]
created: 2026-06-16
source: next-ui session 2026-06-16 (WUI-013/101/113/111, PR #36)
project: github.com/kxlahsimx09/mb-next-admin-portal
---

# ## admin-portal: portal-readable substrate surface + the per-EF CORS gap (2026-0

## admin-portal: portal-readable substrate surface + the per-EF CORS gap (2026-06-16)

Two recurring traps when wiring `mb-next-admin-portal` screens to the `mb-next-payment-gateway` (sinuw) substrate:

### 1. What the portal's `authenticated` JWT can actually READ (RLS surface)
The portal authenticates as gotrue `authenticated` (aal2 admin). The ONLY readable substrate is the 13 `has_read_perm(<resource>)` RLS resources → their view/table:
activity-log→audit_log+callback_queue · bank-transactions→bank_statements · client→v_clients · deposit→v_deposits · deposit-log→slip_verify_attempts · mdr-shared→mdr_shared · merchant→v_merchants · partner→v_partners · payout→**v_payouts_read** · transaction→transactions · wallet→wallet · wallet-log→wallets_change_logs · withdrawal-queue→withdrawal_queue.
As of 2026-06-16 ALL 13 are wired. **NOT readable by the portal (don't wire a mock screen to these):**
- `v_auth_users`/`v_auth_sessions`/`v_auth_mfa_*` → granted to `investigator_ro` ONLY, zero-grant to `authenticated` (so /users, /login-log, /otp-logs are backend-blocked).
- `bank_account` → SV7b zero-grant (so /system-bank, /bank-accounts blocked).
- settlement/topup/mdr_profiles/reports/direct-transfer/pull-out → no read view/RLS yet.
RULE: never point a screen at an ENGINE view to "make it work" — `v_payouts` is the zero-grant engine view; reading it client-side leaks cross-tenant (the retracted-handoff class). The RBAC read surface is `v_payouts_read`. NOT symmetric with v_deposits.
PostgREST can't aggregate a view → deposit tab-counts/summary (SUM/GROUP BY) need a gateway RPC; until then use a bounded facet read.

### 2. Per-EF CORS: new EFs the portal calls need `_shared/cors.ts` `withCors`
A portal→EF `fetch` that is CORS-blocked fails SILENTLY at the network layer (no Playwright error; only `page.on('console'/'requestfailed')` catches it). The `admin-deposit*` EFs carry `withCors`; as of 2026-06-16 these do NOT (→ browser calls fail): `auth-step-up-verify`, `auth-step-up-posture`, `admin-bankbot-log`. Fix = wrap with `withCors` mirroring `admin-deposit/index.ts`. The EF logic itself is fine (callable server-side / via node fetch which ignores CORS).

### Live-test without Vercel (agent worktree has no Vercel auth; deploys are brew-ops-owned)
Test against staging directly: `source ~/.arra-oracle-v2/fleet-secrets/mb-next-payment-gateway/slots/next-ui.env` (synthetic aal2 admin: URL+anon+UI_ADMIN_EMAIL/PASSWORD/TOTP_SECRET). (a) substrate: node + @supabase/supabase-js, replicate the exact `.from()`/`fetch(functions/v1/*)` calls — run the script INSIDE the repo (ESM resolves node_modules by tree, not NODE_PATH). (b) real UI: `.env.local` from next-ui.env → `PORT=3000 npm run start` (shell has PORT=47778 set — override) → playwright-core + cached `chromium_headless_shell`; portal has 0 data-testids, click by localized `title=` (app defaults TH). Always clean up `.env.local`.

---
*Added via Oracle Learn*
