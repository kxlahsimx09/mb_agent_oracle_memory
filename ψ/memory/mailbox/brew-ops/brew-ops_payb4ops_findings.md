# brew-ops — PAYOUT slice-4 CROSS-STACK DEPLOY findings (campaign payb4ops)

**Date:** 2026-06-13 · **Source:** fresh isolated checkout `origin/build/payout-slice4 @ 6d6fcae` (worktree `/tmp/wt-payb4ops-src`, NOT the dev worktree / dev-1) · **PR:** #472 (DO NOT MERGE) · **Deploy owner:** brew-ops (single-owner deploy/EF) · **Targets:** TESTER `yupsev` (`yupsevcrubgprsbujbpu`) + INVESTIGATOR/SEAL `qnccph` (`qnccphgykzdydebmdwdf`).

## VERDICT: ✅ GREEN — both stacks deploy-ready for payb4t probes. ⚠️ ONE cross-lane BLOCKER surfaced (PR-merge only, not a stack blocker).

Deploy set (per dev handoff `next-dev_payb4_findings.md §6`): (1) migration `20260612000250_payout009_reconcile_clock_grace.sql`; (2) EF `payout-resend-callback` `--no-verify-jwt`. No `_shared/*` change beyond the one comment. `deposit-resend-callback` untouched.

---

## ⚠️ CROSS-LANE BLOCKER (surfaced — PR #472 → main merge; NOT a stack-readiness blocker)

**Migration version COLLISION at `20260612000250`.**
- `origin/main` already carries `supabase/migrations/20260612000250_adr10_rm_residual_backfill_run57bd31e7.sql` (PR **#466**, merged `6d3344b`, "gates DEPOSIT L5"). It is applied on BOTH stacks (`schema_migrations` row `20260612000250 = adr10_rm_residual_backfill_run57bd31e7`).
- PR #472 (`build/payout-slice4`) created a **different** file **also** numbered `20260612000250` (`payout009_reconcile_clock_grace`). The branch predates #463(`…240`)+#466(`…250`) — it has neither in its tree.
- On merge to main both `20260612000250_*.sql` files coexist (no git conflict, different names) → the migration runner keys on the `20260612000250` version prefix → **ambiguous / one file silently not applied**. The dev's §6 note ("numbered after …240 #463") missed #466's `…250`.
- **ACTION (dev/architect/reviewer, NOT brew-ops — merging+prod-code are out of my scope):** renumber slice-4's migration file from `20260612000250` to a unique forward-only version `> 250` before #472 merges. I used `20260612000260` on the stacks (see below) — recommend the PR adopt the same.

**Deploy-side resolution (already done):** `supabase db push` is unusable here (it would see `20260612000250` "applied" = the adr10 row and SKIP the slice-4 file). I applied the slice-4 DDL **directly via psql** inside one `BEGIN…COMMIT` (`ON_ERROR_STOP`), and recorded it as `schema_migrations` version **`20260612000260`**, name `payout009_reconcile_clock_grace` (non-colliding, forward-only). DDL is byte-identical to the file (idempotent `DROP IF EXISTS` / `CREATE OR REPLACE`).

---

## PER-STACK CHECKLIST

| # | Verify item | qnccph (SEAL) | yupsev (TESTER) |
|---|---|:---:|:---:|
| 1 | migration recorded (slice-4 DDL applied) | ✅ `…260 payout009_reconcile_clock_grace` (+ `…250 adr10` + `…240 sv8` present) | ✅ same |
| 2 | `sweep_payout_reconcile(interval, timestamptz)` present; OLD 1-arg GONE | ✅ overloads=1, 2-arg only | ✅ same |
| 2 | …SECURITY DEFINER + service_role grant, NO public/anon/authenticated (SV8) | ✅ secdef=t; acl `service_role=X` (+postgres owner); risky_grantees=∅ | ✅ same |
| 2 | …prosrc `COALESCE(p_now, app_now())` + app_now()-relative lookback | ✅ both true | ✅ same |
| 3 | `v_success_payout_audit` grace predicate uses `app_now()` not `now()` | ✅ `(app_now() - p.completed_at) > grace_window`; standalone bare `now()`=0 | ✅ same |
| 4 | EF `payout-resend-callback` NOT 404; real gotrue gate (401 no/garbage bearer) | ✅ deployed `--no-verify-jwt`; POST→401 `missing_bearer_token`; garbage→401 `invalid_token`; anon-key→401 `invalid_token`; GET→405 `method_not_allowed` (fn method-check first ⇒ verify_jwt=false confirmed) | ✅ same |
| 5 | flags/knobs: `payout_auto_reconcile_enabled='true'`; `payout_audit_grace_window='6 hours'`; bank_capabilities memo seed | ✅ true / 6 hours / `bank_capabilities.ktb.payout_memo_carries_request_id=t` | ✅ same |
| 6 | cron `sweep-payout-reconcile` resolves to new signature | ✅ `* * * * *` → `SELECT count(*) FROM public.sweep_payout_reconcile()` (zero-arg → new 2-arg via defaults); live call returns 0 rows | ✅ same |
| 7 | clock/reset RPC sanity | ✅ app_now/clock_set/clock_advance/clock_reset/reset_for_test present; set→advance→reset roundtrip OK; tx-scoped; clock currently **UNSET** (drift 0.0s) | ✅ same |

**Notes on item 5 naming:** the task's shorthand `carries_request_id_in_memo` ≠ the real column `bank_capabilities.payout_memo_carries_request_id` (boolean). The KTB seed row is present (`=t`) on both — readiness satisfied. (Grace-knob spec-name divergence `payout_confirm_grace_minutes` vs deployed `payout_audit_grace_window` is the dev's routed §7.1 — not a deploy item.)

**EF bundle:** redeployed from slice-4 source on both stacks; CLI bundled `index.ts` + `_shared/{db,admin-auth,rbac,login-support,auth}.ts` (dependency closure). Docker-not-running is a benign warning (API/eszip bundler used). The C-B comment fix ships with it.

---

## CROSS-LANE #463 (SV8 revoke) — re-verify: ✅ NO CONFLICT

#463 (`…240 sv8_revoke_payout_fns`) **has merged** and is applied on both stacks. It REVOKEs public/anon/authenticated on 6 OTHER payout fns (`create_payout`, `_payout_stuck_review_minutes`, `mark_failed_from_review`, `sweep_payouts_bank_maintenance`, `sweep_stale_claims`, `sweep_stale_payouts`) — confirmed: all 6 show no risky grantees on both stacks. It does **not** touch `sweep_payout_reconcile`. My new `sweep_payout_reconcile(interval,timestamptz)` was CREATEd *after* `…240` with the SV8 grant from the start (`service_role` only) — grant survives/holds. **No overlap, no conflict.**

(Dev routed §7.2 — latent PUBLIC EXECUTE on the *other* pre-SV8 reconcile/audit fns `_payout_auto_reconcile_enabled`, `reconcile_payout`, `_payout_memo_carries_request_id`, `_payout_audit_grace_window`, `classify_success_payout`, `match_payout_statement` — is a separate routed SV8-batch item, NOT this slice's deploy and NOT a readiness blocker.)

---

## TESTER FIXTURE NOTE (payb4t) — gotrue aal2 identities for the 3-actor + tenant-scope-403 EF legs

**The EF + substrate are READY. The aal2 bearers are the tester's to mint (slice-2 item-7 pattern) — I do NOT invent credentials.**

- **yupsev `auth.users = 0`** and **app_user↔auth.users overlap = 0** → no backing gotrue identities exist. The EF's `adminAuth → verifyGotrueJwt` requires a real gotrue user JWT (aal2). The tester must seed gotrue users + verified TOTP (aal2) and bind each to an existing `app_user` row (`auth.users.id = app_user.id`), then login→verify-TOTP to mint the aal2 access token.
- **The application-side `app_user` identities of every needed tier already exist** on yupsev, and all three hold `payout:resend-callback` (via `role_permissions`):
  | resend tier | `app_user.user_type` / `role` | count | holds `payout:resend-callback` |
  |---|---|---|---|
  | admin (super_admin) | `admin` / `super_admin` | ×2 | ✅ |
  | client | `client` / `client_admin` | ×1 | ✅ |
  | sub-client | `sub-client` / `client_viewer` | ×1 | ✅ |
  | (negative / perm-deny actor) | `partner` / `partner_user` | ×2 | ❌ (no resend perm — usable for a `requirePermission` 403 leg) |
- **Tenant-scope-403 leg (§ADR-13 F4):** for a client/sub-client caller, set the fixture payout's `ts_payouts.client_id` to a *different* client than the actor's `app_user.client_id` → EF returns `403 {"error":"forbidden","detail":"cross_tenant_access_denied"}`. Admin tier bypasses tenant scope. (`client` table has 5 rows to draw distinct tenants from.)
- **SEAL qnccph** has `auth.users = 2` (2 gotrue users present) + the same app_user tier set; the EF is deployed+gated identically. If the investigator exercises the 3-actor EF legs directly it will also need aal2 bearers (same minting path); the seal's core re-derivation is SQL-level.

---

## RAW EVIDENCE SUMMARY (both stacks, identical unless noted)

- Pre-state: `sweep_payout_reconcile` = old 1-arg only; view grace predicate = bare `now()`; `…250` row = adr10 backfill (NOT slice-4). My slice-4 DDL was never applied (the recorded 250 ≠ slice-4).
- Baseline biz footprint 0/0/0 (ts_payouts/bank_statements/callback_queue) on qnccph — clean.
- Apply: `BEGIN; \i 20260612000250_payout009_reconcile_clock_grace.sql; INSERT schema_migrations(…260); COMMIT;` → `DROP FUNCTION / CREATE FUNCTION / REVOKE / GRANT / CREATE VIEW / INSERT 0 1 / COMMIT` on both.
- Post-apply verify: items 1–3,5–7 GREEN (queries above). EF (item 4) deployed `--no-verify-jwt`; gate bodies = fn's own (`missing_bearer_token`/`invalid_token`/`method_not_allowed`), not platform shape.
- Connection: IPv4 session pooler `postgres.<ref>@aws-1-ap-southeast-1.pooler.supabase.com:5432`, DB pw from slot env. EF deploy: PAT `SUPABASE_ACCESS_TOKEN` + `--project-ref`.

## STATUS / NEXT
- ✅ Both stacks GREEN → **stack-ready signal to next-tester (payb4t)**.
- ⚠️ Surface the `…250` migration collision to dev/architect/reviewer for PR #472 (renumber to `…260` before merge).
- Out of scope (untouched): sinuw/dev-1/livegate/authfull; merging; `match_payout_statement`/`mark_success`; `deposit-resend-callback`.
