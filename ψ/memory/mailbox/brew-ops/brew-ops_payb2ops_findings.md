# brew-ops — PAYOUT slice-2 CROSS-STACK DEPLOY + stack-readiness gate — findings

**Campaign:** payb2ops · **Actor:** brew-ops (all-slots) · **Date:** 2026-06-12
**Source:** `origin/build/payout-slice2` @ `3e2b778` (PR #449) — isolated detached worktree at `/tmp/payb2-slice2-src` (the dev's `wt-c-payb2` and `dev-1` were NOT touched).
**Targets:** TESTER `yupsev` (`yupsevcrubgprsbujbpu`) · INVESTIGATOR/seal `qnccph` (`qnccphgykzdydebmdwdf`)
**Handoff:** `next-dev_payb2_findings.md` §6 (deploy set) — both stacks were already at full main parity incl. the out-of-order `20260612000070` (DEPOSIT-lane, PR #441), so the dev's option (a)/(b) note about `000070` is **MOOT**; only the 2 new slice-2 migrations + 2 EFs were applied.

---

## TL;DR — STACK-READY (with ONE named tester-fixture caveat)

- **Migrations + RPCs + config + cron + EFs: GREEN on BOTH stacks**, byte-identical across the two. Items 1–6 all pass.
- **Item 7 (TESTER only) = AMBER/BLOCKER for the EF-gate probe legs:** the `super_admin` `app_user` (`probe-admin`) exists, but the tester stack has **ZERO gotrue identities** (`auth.users` = 0) → **no aal2 admin JWT can be minted yet**. The direct-RPC money-assertion legs (service-role) are **unblocked**; the **HTTP EF-gate** legs need the tester to seed a gotrue identity first (named below).
- **Signal to next-tester (payb2t):** the substrate is ready for the money/RPC suites NOW on both stacks. EF-gate-via-real-JWT probes on the tester need the §"Item 7" fixture seeded first.

## Deploy mechanics (how it was applied)

- **Migrations:** `supabase db push --db-url <session-pooler>` from `/tmp/payb2-slice2-src` (CLI 2.104.0). Pre-flight diff (local vs remote `supabase_migrations.schema_migrations`) confirmed the ONLY local-not-applied migrations were `…000130` + `…000140` (zero remote-not-in-local divergence) on **both** stacks; `--dry-run` confirmed exactly those two would push, in order. No `--include-all` needed (both > the `…000120` head; `…000070` already present). Recorded with full `statements[]` + `name` bookkeeping by the CLI.
- **Edge Functions:** `supabase functions deploy admin-payout-cancel admin-payout-reconcile --project-ref <ref>` with the slot's `SUPABASE_ACCESS_TOKEN` (PAT). API bundler path (Docker-not-running warning is benign); `_shared/{db,admin-auth,rbac,login-support,auth}.ts` bundled. `_shared/admin-auth.ts` / `auth.ts` UNCHANGED (no authfull collision). `config.toml` carries explicit `verify_jwt=false` for both EFs → the EF owns its auth gate.

---

## Per-stack per-item checklist

Legend: ✅ GREEN · ⚠️ AMBER (needs a fixture, not a deploy defect) · ❌ RED

| # | Gate item | TESTER (yupsev) | INVESTIGATOR (qnccph) |
|---|-----------|-----------------|------------------------|
| 1 | migration list shows `000130` + `000140` applied | ✅ both rows present (`payout004_reconcile_failed_from_review`, `payout004_sweep_appnow_config`) | ✅ both rows present |
| 2 | RPCs resolve (signatures + prosrc) | ✅ (see breakdown) | ✅ (see breakdown) |
| 3 | `app_settings.payout_stuck_review_minutes` seeded (default 5) | ✅ value `5`; `_payout_stuck_review_minutes()` returns `5` | ✅ value `5`; reader returns `5` |
| 4 | `sweep-stale-claims` pg_cron job re-pointed to new signature | ✅ `* * * * *` → `SELECT count(*) FROM public.sweep_stale_claims(500)` | ✅ identical |
| 5 | EFs respond not-404 w/ real auth gate (401 `missing_bearer_token` on no-token) | ✅ cancel + reconcile → **HTTP 401 `{"error":"missing_bearer_token"}`**; GET → 405 `method_not_allowed` (live routing, not 404) | ✅ identical |
| 6 | clock/reset RPCs still present (unchanged, sanity) | ✅ `app_now`, `clock_set(timestamptz)`, `clock_advance(interval)`, `clock_reset`, `reset_for_test` all present | ✅ identical |
| 7 | TESTER: usable `super_admin` admin fixture for EF-gate probes | ⚠️ **BLOCKER for EF-gate-via-JWT legs** — `app_user` `probe-admin` (super_admin) exists but `auth.users`=0 → no aal2 JWT mintable. Fixture to seed named below. | n/a (item 7 is tester-scoped; seal uses service-role direct-RPC for AR2) |

### Item 2 — RPC breakdown (identical on both stacks)

| RPC | Result |
|-----|--------|
| `mark_failed_from_review(uuid,text,text)` | ✅ present; identity args `p_queue_id uuid, p_error_message text, p_failure_code text`; `SECURITY DEFINER` = t; `service_role` EXECUTE granted |
| `sweep_stale_claims(int,timestamptz)` | ✅ present; identity args `p_batch_size integer, p_now timestamp with time zone`; `SECURITY DEFINER` = t. **Old `sweep_stale_claims(interval)` overload is GONE** (dropped) — the new signature is the single canonical function |
| `_payout_stuck_review_minutes()` | ✅ present; returns `integer` |
| `admin_reconcile_payout(...)` | ✅ present; `pg_get_functiondef` **contains `mark_failed_from_review`** and does **NOT** contain a bare `PERFORM mark_failed(` → the FAILED leg is correctly re-pointed (DRIFT-A closed) |
| `admin_cancel_payout(...)` | ✅ present; args `p_payout_id uuid, p_actor_id uuid, p_actor_username text, p_reason text` |

---

## Item 7 — TESTER super_admin admin fixture (DETAIL + what next-tester must seed)

**Observed on yupsev:**
- `app_user` super_admins: exactly **one** — `id=88888888-8888-8888-8888-000000000001`, `username=probe-admin`, `user_type=admin`, `role=super_admin`. (Investigator has 2 super_admin `app_user` rows — context only.)
- `auth.users` = **0 rows** (postgres can read `auth.*`; the count is authoritative — the stack has no gotrue identities at all). The `probe-admin` row therefore has **no** gotrue user, **no** password, **no** MFA factor.
- `public.admin_profiles` exists; **0** rows carry an `allowed_ips` allowlist → the §ADR-2 IP-allowlist branch in `adminAuth` (`enforceIpAllowlist`) **passes** (no allowlist ⇒ pass). So the IP leg is NOT a blocker; the only missing piece is the aal2 identity.

**Why this blocks the EF-gate-via-JWT probes (and only those):** `adminAuth` (`_shared/admin-auth.ts`) requires a **real gotrue JWT** (signature/alg/iss/exp/aud verified — no stub fallback), `aal === "aal2"`, then resolves the actor by `app_user WHERE id = claims.sub`. With zero gotrue users there is no token to present, so `payout:cancel` / reconcile cannot be exercised over HTTP with a real admin identity. **The money-invariant legs are unaffected** — they can call `admin_reconcile_payout` / `admin_cancel_payout` / `sweep_stale_claims` directly via the **service-role** key (the dev's gate note sanctions this).

**What next-tester (payb2t) must seed on yupsev — DO NOT INVENT CREDENTIALS (brew-ops did not):**
1. **A gotrue identity** via the canonical `mintGotrueBearer` / qnccph-seal-stack pattern (same shape as next-ui's `UI_ADMIN_*` triplet on sinuw): email + password, **plus an enrolled & VERIFIED TOTP factor** (`auth.mfa_factors` `factor_type='totp'`, `status='verified'`) so login lands on the CHALLENGE branch and yields a **repeatable aal2** token. Set `app_metadata.entity_type` (rides the JWT; read by `enforceIpAllowlist` — passes with no `admin_profiles` allowlist). `app_metadata.role` is a display hint only.
2. **The `app_user.id == gotrue sub` invariant.** Either (a) mint the gotrue user with `id = 88888888-8888-8888-8888-000000000001` so it aligns with the existing `probe-admin` super_admin row, **or** (b) insert a fresh `app_user` (`role='super_admin'`, `user_type='admin'`) whose `id` equals the minted sub. If `sub` has no matching `app_user` row, `adminAuth` returns `401 unknown_user`.

Once seeded, the EF-gate probes should: no-token → `401 missing_bearer_token` (already verified live); aal1/forged → `401`; valid aal2 super_admin → reach `payout:cancel` / reconcile.

---

## Out-of-scope (untouched, per brief)

sinuw/staging · dev-1 · livegate · authfull PRs #443–446 · no merges · no production code touched. The isolated source worktree `/tmp/payb2-slice2-src` is disposable (detached HEAD @ 3e2b778); the dev's `wt-c-payb2` was read-only for the §6 handoff.

## Evidence anchors

- migration diff + dry-run: local-not-in-remote = {`20260612000130`,`20260612000140`} on both stacks; `db push` applied both, in order.
- `supabase_migrations.schema_migrations`: both versions + names present on both stacks.
- `pg_proc` / `pg_get_functiondef` checks: all item-2 RPCs as tabled.
- `app_settings` + `_payout_stuck_review_minutes()` = 5 on both.
- `cron.job` `sweep-stale-claims` = `* * * * *` → `sweep_stale_claims(500)` on both.
- EF curl probes (apikey, no Authorization): 401 `missing_bearer_token` (POST) / 405 (GET) on both stacks, both functions.
- `app_user` / `auth.users` / `admin_profiles` counts on yupsev as detailed in §"Item 7".
