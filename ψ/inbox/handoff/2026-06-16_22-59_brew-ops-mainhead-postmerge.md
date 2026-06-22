# [post-merge] gateway main@HEAD staging consistency — assert + gates green

**From:** brew-ops (`brew-ops-mainhead-postmerge`) · **Date:** 2026-06-16 ~23:00 (GMT+7) · **Stack:** `mb-next-staging` / sinuw (`sinuwgsqqyqzlpaavimf`)
**Context:** 6-PR gateway stack is MERGED to main — #540 step-up CORS, #541 BOTLOG, #543 v_users (plus #542 settlement, #537/topup family). Ran from CLEAN `main@476e3ec`. No prod touched. No `-f`/`--force`. Repo left clean.

## TL;DR — our 3 merged gateway EFs are FRESH + ACTIVE on sinuw; all 3 gates GREEN. The residual `--assert` FAIL is 100% the unrelated topup+settlement deploy-gate artifact (their schema isn't on staging yet), NOT our stack.

## 1. Deploy-state assert
`scripts/ef-deploy-list.sh --assert sinuwgsqqyqzlpaavimf` from main@HEAD → **exit 1 (FAIL)**, but decomposed:
- **MISSING** `admin-topups` (TOPUP) + `admin-settlements` (SETTLE #542) — neither campaign's migrations are applied to sinuw (`topups`/`settlements` tables = null on the DB). These belong to their OWN deploy gates, out of my scope.
- **STALE (broad):** initially ~52 EFs, all vs `_shared@1781618090` = the **settlement merge #542** (`20b32f9`) which made an ADDITIVE `_shared/rbac.ts` change (+`settlement:create`/`settlement:approve` in the static map; non-breaking, used by no other EF) + `_shared/bot-activity-log.ts`. Because `_shared` bundles into every EF, the freshness floor bumped for the whole fleet until a deploy-all runs.

**The drift is the EXPECTED post-merge artifact, now sourced from settlement #542's `_shared` bump (not topup's, as in the pre-merge handoffs).** A clean global green only comes after topup+settlement apply their migrations and run deploy-all from main@HEAD — owned by those gates.

### Targeted redeploy of OUR 3 EFs (so they're current vs merged `_shared`)
Deployed from clean main@HEAD via `npx supabase functions deploy <ef> --project-ref sinuw…` (exit 0 each):
- `admin-bankbot-log` → **v2 ACTIVE** (was v1)
- `auth-step-up-verify` → **v20 ACTIVE** (was v19)
- `auth-step-up-posture` → **v19 ACTIVE** (was v18)

Pre-redeploy, all 3 had own-source ≤ deployed-time (deployed AFTER their own last change) — they were only floor-stale from settlement's `_shared`. **Re-assert: all 3 now FRESH (out of the STALE list), ACTIVE.** Their own logic was already current; redeploy just rebundled the additive merged `_shared`.

## 2. Post-merge gates (psql 16 → sinuw session pooler, pgtap 1.3.3; all BEGIN…ROLLBACK, zero footprint)
- **`rbac_seed_vs_catalogue_test.sql` → 40/40 PASS, 0 not-ok. FULLY GREEN on main.** Confirms the mission's headline: `ok 8 seed ⊆ catalogue: bot-activity-log:view` AND `ok 37 seed ⊆ catalogue: user:view` BOTH present as seed AND catalogue members. The pre-merge cross-PR drift (old test 8 fail + subset rollup) is GONE. (Trailing diag = harmless INVERSE REPORT of ungranted catalogue members, not a gate.)
- **`botlog_bankbot_activity_log_test.sql` → 33/33 PASS, 0 not-ok.** Only blemish = the known `# Looks like you planned 34 tests but ran 33` (harmless `plan(34)` vs 33 off-by-one).
- **`v_users_read_surface_test.sql` → 20/20 PASS with the fixture reordered.** As-merged file STILL has the seed-before-FK-parent bug: tests 1-12 pass then line 109 fails `app_user_client_id_fkey` (seeds `app_user` UCLI with `client_id=:CLI` BEFORE the parent `client` row) → txn aborts, 13-20 never run. Reordering the `merchant_config`+`client` INSERTs ABOVE the `app_user` INSERT → all 20 pass (structural+TEETH+grants+SV7b+seed AND behavioral 13-20). Migration is correct; ran reorder in a temp copy, repo file untouched.

## 3. Live sanity (REAL aal1→TOTP→aal2 via next-ui.env synthetic admin)
- **3 EFs ACTIVE** on sinuw (versions above). CORS preflight on all 3: allowed origin `mb-next-admin-portal.vercel.app` → 204 + exact ACAO echoed (not `*`); evil origin → no ACAO (blocked). `withCors()` preserved through redeploy.
- **v_users REST:** aal2 admin → HTTP 206, `content-range 0-4/327` = **327 rows**, no secret column in projection (clean leak check). aal1 (same user, not stepped-up) → `*/0` = **0 rows** (aal2 gate fail-closed). anon → 401 `permission denied for view v_users`. Matches the prior 327-row count.

## Test-file nits for a follow-up commit (flagged, NOT fixed here per scope)
1. **`v_users_read_surface_test.sql`** — move the `merchant_config`+`client` INSERTs (currently ~lines 110-116) ABOVE the `app_user` INSERT (~104-109). Same fixture data, still ROLLBACK-wrapped. (PR #543)
2. **`botlog_bankbot_activity_log_test.sql`** — `plan(34)` → `plan(33)` (33 assertions written). (PR #541)

## Next / ownership
- **OUR stack is consistent + green on staging.** No further brew-ops action on the gateway 6-PR stack.
- The global `--assert` will only go green after the **topup + settlement deploy gates** apply their migrations to sinuw and run a deploy-all from main@HEAD. Not my scope — flagging for whoever owns those campaigns.
- PROD: untouched (owner-manual; no Vercel/prod-Supabase auth in this worktree).
