# [for next-ui] BOTLOG deployed to staging — re-run the WUI-130 smoke

**From:** brew-ops (`brew-ops-botlog-deploy`) · **Date:** 2026-06-16 ~19:25 (GMT+7) · **Stack:** `mb-next-staging` / sinuw (`sinuwgsqqyqzlpaavimf`)
**Closes the staging-deploy half of:** next-dev (`next-dev-bankbot-botlog`) branch `feat/botlog-bankbot-activity-log` · PR #541 (OPEN, owner-gated — NOT merged; staging validation precedes the owner merge, same precedent as the step-up CORS deploy).

## TL;DR — GREEN. Re-run the WUI-130 "Bankbot Logs" browser smoke. The page will show LIVE rows, not empty-state.

## 1. Migrations applied (3, in order, idempotent)
Applied via the Management-API SQL endpoint (targeted — NOT `db push`, see Note A) and recorded in `supabase_migrations.schema_migrations`:
- `20260616000050_botlog_bankbot_activity_log.sql` — table + RLS + `bankbot_logger` role (NOLOGIN, granted to `authenticator`) + append-only triggers + rate-guard
- `20260616000060_botlog_read_views.sql` — `v_bankbot_activity_stream` + `v_bankbot_fleet_now` (service_role-only)
- `20260616000070_botlog_rbac_seed.sql` — seeds `('super_admin','bot-activity-log:view')`

Post-migration DB checks (Management API): table RLS=on; both views exist; `bankbot_logger` NOLOGIN + granted to authenticator; INSERT policy `bankbot_insert_own` present; seed row present.

## 2. Deploy mode: TARGETED (13 EFs by name) — NOT deploy-all
Deployed `admin-bankbot-log` first (derisk), then the 12 re-bundled bot EFs (`bot-claim/fetch-processing/queue-mark/transfer-proof/tx-checkpoint/heartbeat/statements/bank-statements-last/config/otp/otp-log/balance`) — they each genuinely changed in BOTLOG commit `d6fb71a` (the `_shared/bot-activity-log.ts` G5 emitter wiring).
- `admin-bankbot-log`: ACTIVE v1 (new).
- All 12 bot EFs: bumped one version, all ACTIVE (asserted pre/post — none left stale or broken).
- Total deployed = **52** (51 baseline + admin-bankbot-log), all ACTIVE.

**Why NOT deploy-all (deviation from the mission's deploy-ALL note):** this branch sits on a main that already carries the in-flight TOPUP campaign (PR #537) — 4 topup migrations + a 52nd EF `admin-topups` + a `_shared/rbac.ts` change, none deployed to staging. A blanket `db push`/deploy-all would have dragged the topup campaign onto staging. The prior brew-ops step-up CORS handoff (`2026-06-16_18-42`) explicitly set the policy: *"Do not deploy-all from this branch — admin-topups + topup _shared are owned by the topup deploy gate."* So I deployed only my 13 BOTLOG EFs by name. The mission's deploy-ALL note is the PROD runbook (clean main@HEAD); on this branch targeted is correct.

### ef-deploy-list.sh --assert result: **exit 1 (FAIL) — but it's the known cross-campaign branch artifact, NOT my EFs**
`scripts/ef-deploy-list.sh --assert sinuwgsqqyqzlpaavimf` → `source=53 ACTIVE-deployed=52`, FAIL with:
- `MISSING admin-topups` (the topup-gate EF — not mine).
- ~39 EFs reported STALE vs `source _shared@1781611380`. That floor is bumped by the topup `_shared/rbac.ts` on this branch; those EFs' OWN sources are unchanged. **All 13 of my BOTLOG EFs are FRESH (none in the stale list)** — verified individually. A clean `--assert` green only comes after topup merges and a deploy-all from main@HEAD runs.

## 3. Post-deploy gates (live psql via session pooler — psql installed this session)
Ran against the sinuw session pooler (`aws-1-ap-southeast-1.pooler.supabase.com:5432`, SESSION mode):
- **GATE 1 — `botlog_bankbot_activity_log_test.sql`:** 33/33 run assertions PASS, **zero `not ok`**. Note: the file declares `plan(34)` but only 33 assertions are written → harmless **off-by-one in the PR's own test plan count** (not a deploy/DB failure). All DB enforcement (structure, append-only, role scoping, RLS own-account, allowlist, no-read, views, seed) is verified. Whole run BEGIN…ROLLBACK — zero footprint (the test's `...00aa` account is gone). **Suggest next-dev fix `plan(34)`→`plan(33)` in PR #541.**
- **GATE 2 — `rbac_seed_vs_catalogue_test.sql`:** 39/39 PASS, including `ok 8 - seed ⊆ catalogue: bot-activity-log:view`. Subset invariant stayed green with the new member.

## 4. Browser-side verification (the proof for your smoke)
- **Preflight** `OPTIONS` (Origin `https://mb-next-admin-portal.vercel.app`) → **204**, `access-control-allow-origin: https://mb-next-admin-portal.vercel.app` echoed (not `*`). Disallowed origin → 204 with NO ACAO (blocked).
- **Auth gate:** POST without bearer → 401 fail-closed. The EF gates on DB-fresh `bot-activity-log:view`, so you need a **super_admin aal2** session.
- `PORTAL_ALLOWED_ORIGINS` set on sinuw EF runtime (confirmed via secrets API + the live preflight echo).

### NOT empty-state — the page already has LIVE data
Deploying the 12 bot EFs lit up the G5 emitter: the staging bot fleet immediately wrote **real `source:"gateway"` rows** (`cursor_read` / `statements_push` for bot accounts `7777…0001/0002`, timestamps right after deploy). At handoff: `bankbot_activity_log` = 9 rows, `v_bankbot_activity_stream` = 9, `v_bankbot_fleet_now` = 2. So `fleet_now`/`stream` will return populated `{rows:[…]}`, not `{rows:[]}` — expect the WUI-130 grid to render live bot activity.

## What's next for next-ui
Re-run the WUI-130 "Bankbot Logs" browser smoke as super_admin (aal2). Expect: page loads, `fleet_now` shows ~2 bot rows, `stream` shows the gateway-source feed, no CORS error. `resolve_proof` has no proof rows yet (Phase-1 gateway events carry no proof_url), so don't expect a signed-URL path to exercise until bb2proof (Phase-1b) lands.

## Safety / scope notes
- Did NOT merge PR #541 (owner-gated). Did NOT touch prod. No `-f`/`--force`. Did NOT deploy `admin-topups` or apply the 4 topup migrations (other campaign's gate).
- Installed `postgresql-client` (psql 16) on the dev box for the pgTAP gate — env-only change, no repo impact.

## Fallback path
`/home/ubuntu/Code/github.com/kxlahsimx09/mb_agent_oracle_memory/ψ/inbox/handoff/2026-06-16_HH-MM_brew-ops-botlog-deploy.md`
