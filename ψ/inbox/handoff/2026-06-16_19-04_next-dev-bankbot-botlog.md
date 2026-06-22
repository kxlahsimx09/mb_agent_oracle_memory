# [for brew-ops] BOTLOG bankbot-log EF + migration ready to apply+deploy (sinuw)

**From:** next-dev (`next-dev-bankbot-botlog`)
**Repo:** `kxlahsimx09/mb-next-payment-gateway`
**Branch:** `feat/botlog-bankbot-activity-log`  ·  **PR:** #541 (DO NOT MERGE — owner-gated)
**Worktree:** `/home/ubuntu/Code/github.com/kxlahsimx09/mb-next-payment-gateway.wt-botlog`

## What this builds
The missing data slice + read EF behind the admin-portal WUI-130 "Bankbot Logs" screen (campaign bb2botlog, §ADR-15 §Amendment 2026-06-15, BL1–BL9). The portal consumer (`monitoring-api.ts` → `efPost("admin-bankbot-log", …)`) was already shipped; this is the gateway side it binds to. Phase-1 only (gateway-observed events; no bot redeploy needed).

## APPLY + DEPLOY STEPS (run on the target stack — sinuw, then any other live stack)

### 1. Apply the 3 migrations (in order)
```
supabase/migrations/20260616000050_botlog_bankbot_activity_log.sql   # G1 table+RLS+role+append-only+rate-guard
supabase/migrations/20260616000060_botlog_read_views.sql             # G2 v_bankbot_activity_stream + v_bankbot_fleet_now
supabase/migrations/20260616000070_botlog_rbac_seed.sql              # G3 seed super_admin -> bot-activity-log:view
```
All idempotent (IF NOT EXISTS / ON CONFLICT / DROP-then-CREATE). No seed step beyond G3 (the seed IS migration G3 — no separate brew-ops seed command). The `bankbot_logger` role is created `IF NOT EXISTS` and granted to `authenticator`.

### 2. Deploy the EFs from clean main@HEAD after merge (per runbook docs/runbooks/edge-function-deploy.md §3)
```
git checkout main && git pull
source <stack-slot>                                  # exports SUPABASE_ACCESS_TOKEN
supabase functions deploy --project-ref <REF>        # deploys EVERY dir incl. the NEW admin-bankbot-log + the 12 re-bundled bot EFs
scripts/ef-deploy-list.sh --assert <REF>             # PROVE nothing excluded / stale (53 EFs now incl. admin-bankbot-log)
```
NOTE: the 12 bot-facing EFs (bot-claim/fetch-processing/queue-mark/transfer-proof/tx-checkpoint/heartbeat/statements/bank-statements-last/config/otp/otp-log/balance) all changed (G5 helper wiring via `_shared/`), so a deploy-ALL is required — a partial sweep would leave them stale. `admin-bankbot-log` is auto-included in `ef-deploy-list.sh`.

### 3. Post-deploy gate (live SQL test — no local PG in the dev env)
```
psql "$DB_URL" -tA -f supabase/tests/botlog_bankbot_activity_log_test.sql   # 34 pgTAP assertions, BEGIN…ROLLBACK
```
Also re-run `supabase/tests/rbac_seed_vs_catalogue_test.sql` (gains the `bot-activity-log:view` member; seed ⊆ catalogue must stay green).

### 4. Verify against the portal
Hit the portal /bankbot-logs page (super_admin, aal2). fleet_now + stream should 200 with `{ rows: [] }` until bot traffic flows; once any bot EF is hit, gateway-source rows appear.

## The scoped role/perm to seed (already IN the migrations — listed for your records)
- **DB role:** `bankbot_logger` (NOLOGIN, INSERT-only on `bankbot_activity_log`, granted to `authenticator`) — created by G1.
- **RBAC perm:** `('super_admin','bot-activity-log:view')` — seeded by G3 into `role_permissions`. EF gates DB-fresh on it (evidence-read-url pattern; NOT the compile-time map, since `:view` perms are seed-only).

## CORS
The EF is wrapped with `withCors` (mirrors admin-deposit), so it works browser-side immediately. Ensure `PORTAL_ALLOWED_ORIGINS` env on the stack includes the portal origin (same env the other portal-facing EFs use — already set if admin-deposit works).

## NOT in this PR (Phase-1b — bb2proof + bot deploy gated, do NOT block on it)
- G7 `mint-bankbot-log-token` (or a brew-ops sign script: `{role:'bankbot_logger', bank_account_id, iss, aud, iat, exp~30-60d}` with the project JWT secret) → bot fleet-secret `BANKBOT_LOG_JWT`.
- G8 `storage.objects` INSERT policy `bankbot_upload_own` for the `bankbot/<acct>/…` lane in the `bot-proof` bucket (lives WITH bb2proof's bucket migration).
- B1/B2/B3 bot-side env + emitter + 8 emit points.
The `bankbot_logger` role + own-account INSERT RLS ship now, so Phase-1b is purely additive (mint a token + add the storage policy + deploy the bot).

## EF name
`admin-bankbot-log` (POST). Modes: `stream` / `fleet_now` / `resolve_proof`. resolve_proof signs `bot-proof` 60s TTL + audits `evidence_view` fail-closed.

## Gate status (local, dev env has no PG/Docker)
- bun rbac + cors tests: 24 pass (ROLE_PERMISSIONS map unchanged).
- All new/modified TS transpiles clean; every file ≤ 250 lines.
- pgTAP slice test written, runs post-deploy on the live stack (step 3).
