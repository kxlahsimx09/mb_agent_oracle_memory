# next-code-reviewer — PAYOUT slice-2 (review/cancel safety rails) — Step-3 review findings

**Campaign:** payb2r · **Branch (mine):** `campaign/payb2r` · **Date:** 2026-06-12
**Reviewed:** PR **#449** (build: `build/payout-slice2` @ `877e7e7`) + PR **#451** (test-only probes: `test/payb2-probes` @ `ec3d946`)
**Dimensions:** requirement-fidelity · clean-code · perf/safety. **Method:** read the v2 SPEC + both migrations + both EF diffs + every probe file directly; cross-checked the substrate claims against the merged slice-1 functions (`mark_failed`, `mark_success`, `mark_review`, prior `admin_reconcile_payout`); read the dev/tester/brew-ops sibling findings as corroboration only (not as a substitute for reading the code).

## VERDICTS

| PR | Verdict | Gate |
|---|---|---|
| **#449** build | ✅ **APPROVE** | self-merge only after this APPROVE **and** investigator GREEN (§9a build-code carve-out). DO NOT MERGE by me. |
| **#451** test | ✅ **APPROVE** | same gate; test-only, PENDING-DEPLOY semantics correct. |

Both verdicts route through the orchestrator. No code edited (review-only).

---

## PR #449 — build — APPROVE

### Requirement fidelity (vs SPEC v2 §2/§3 + epic PAYOUT-004/005 + the slice-1 substrate)

**(1) `mark_failed_from_review` — faithful sanctioned `review → failed` producer. ✓**
- **Own review-source CAS guard, lock-first:** `SELECT … FROM withdrawal_queue … FOR UPDATE` → `SELECT … FROM ts_payouts … FOR UPDATE` → `IF NOT FOUND OR v_payout.status <> 'review' THEN RETURN` (benign no-op, lock-first-wins). Canonical lock order `withdrawal_queue → ts_payouts → wallet`. ✓
- **Release frozen-only, balance untouched:** `UPDATE wallet SET frozen = frozen - v_total`; the `payout_unfreeze` `wallets_change_logs` row carries `balance_before == balance_after` (balance never read-modified). No partner fan-out, no residual on the failed path. ✓
- **Callback BYTE-IDENTICAL to slice-1 `mark_failed`'s `payout.failed`:** field-by-field diff of the `jsonb_build_object` + the `clientReferenceId iff ref_code` rider is **identical** to `20260612000120`'s block (`event/txnId/amount/fee/status:'FAILED'/failureCode/failureMessage`). The *only* difference between the two RPC bodies is the internal change-log `note` text (`'mark_failed_from_review unfreeze (…review reconcile, <code>)'`) — a **desirable** provenance distinction in the audit trail; the client-facing callback is byte-identical. ✓
- **`failure_code` default `system_error`:** `p_failure_code text DEFAULT 'system_error'` + `coalesce(p_failure_code,'system_error')`, and the validation set `{bank_timeout,claim_timeout,system_error}` matches `mark_failed`. `admin_reconcile_payout` passes only 2 args → defaults to `system_error`. ✓
- **CRITICAL — SM2-SPLIT lock preserved:** this PR does **not** touch `mark_failed` (no CREATE OR REPLACE on it anywhere in the delta). `mark_failed` stays `processing`-ONLY; the new RPC is `review`-ONLY. The dangerous late-bot `review → failed` clawback path remains structurally locked out of `mark_failed`. **Nothing widens the split.** ✓

**(2) `admin_reconcile_payout` re-point. ✓** Diffed full-body vs the prior `20260519000006`: the **only** change is the failed-leg line `PERFORM mark_failed(…)` → `PERFORM mark_failed_from_review(v_queue_id, p_reason)` (+ comment). Success leg (`mark_success`, which accepts `review` and RAISEs `mdr_over_allocated` on `residual<0` — uncaught here, so the **PV1-R fail-close is inherited** and the whole reconcile rolls back → stays `review`, no audit, no callback, EF 500), Layer-1 validation (`not_found`/`not_review`), queue resolution, the §ADR-13 D1/D2 envelope (`write_audit_log` + `audit_id` echo), and the return shape are all **unchanged**.

**(3) Sweep rewrite (`20260612000140`). ✓** `(p_batch_size int DEFAULT 500, p_now timestamptz DEFAULT NULL)`, `v_now := COALESCE(p_now, app_now())` (§ADR-20 T4 — no wall-clock `now()` on the predicate); threshold via `_payout_stuck_review_minutes()` (fail-safe default 5; bound relative-to-knob); `routed_to` is **always `'review'`** (never-auto-fail; the auto-fail branch is gone); `SECURITY DEFINER` + `GRANT EXECUTE … TO service_role` (minimal, not PUBLIC); per-row `BEGIN…EXCEPTION WHEN OTHERS THEN CONTINUE` subtxn isolation so one bad row never stalls the tick. The old `(interval)` overload is dropped cleanly (`DROP FUNCTION IF EXISTS sweep_stale_claims(interval)`), and the cron re-point is **idempotent + pg_cron-guarded** (`IF EXISTS pg_extension` → unschedule-if-present → schedule `sweep_stale_claims(500)`).

**(4) Migration safety. ✓** Forward-only; every statement idempotent (`CREATE OR REPLACE`, `INSERT … ON CONFLICT (key) DO NOTHING`, `DROP FUNCTION IF EXISTS`, guarded `DO` block). The single `DROP` targets the **superseded** `(interval)` overload by design — its sole caller (the cron) is re-pointed in the same migration, and brew-ops confirmed the old overload is GONE on both stacks. No destructive data ops. `app_settings.key` ON-CONFLICT relies on the existing unique constraint (verified live — seed succeeded, value=5 both stacks).

**(5) The 2 EF edits are comment-only. ✓** Both diffs touch only `/** … */` doc-comment lines (the "JWT (stub)" → real gotrue+aal2+RBAC correction, and the reconcile header naming `mark_failed_from_review`). Zero executable-line diff → zero behavior change.

**(6) No `_shared/*` edits; no deposit-lane files; §9a carve-out honored. ✓** Delta = 2 migrations + 2 payout EFs + 3 doc files (SPEC, broadcast pointer, dev findings). `git diff --name-only` shows **no** `_shared/*` (authfull #445 collision avoided) and **no** deposit-lane file. The migrations CREATE-OR-REPLACE only payout/new functions (`mark_failed_from_review`, `admin_reconcile_payout`, `sweep_stale_claims`, `_payout_stuck_review_minutes`) — no sealed deposit-lane function touched.

**Deployed == source check:** the only commit after brew-ops' deploy sha `3e2b778` is `877e7e7` (SPEC-doc re-broadcast of v2 §5.7 RPC params); `git diff 3e2b778..877e7e7 -- supabase/` is **empty**. So the tester's 46/46 VERIFY (and brew-ops' both-stack deploy verification) cover the *exact* code at the current PR head.

### Non-blocking observations (#449) — route, do not gate
- **NB-1 (pre-existing, not introduced):** `admin_reconcile_payout` Layer-1 reads `ts_payouts` **without** `FOR UPDATE` before the delegated RPC takes the lock — a TOCTOU window. The delegated RPC re-asserts `status='review'` **under lock**, so there is **no double money move** (money-safe). On a concurrent status flip, the reconcile could still write an audit row + return `reconciled` with no money moved. Identical in the prior `20260519000006` — **not a regression**, and admin actions are effectively serialized. A future slice could `FOR UPDATE` in Layer-1.
- **NB-2:** `mark_review` has no positive `processing`-source assert (only a `review`-idempotency early-return). Already routed by the dev (§7.3). The sweep predicate constrains the source to `claimed`/`processing`, so it is money-safe in practice.
- **NB-3:** the `(interval)` DROP is destructive only to a superseded overload whose sole in-repo caller is re-pointed in the same file; verified GONE on both stacks. Intentional.

---

## PR #451 — test-only probes — APPROVE

### Requirement / de-bias / hygiene

- **Binds the SPEC, not the impl (de-bias layer-1). ✓** Grep for any `supabase/(functions|migrations)` import or read across all probe files = **clean**. `_spec-rc.ts` carries verbatim SPEC `§`-clause quotes; every `ok(...)` row appends a `:: ${R.quote.*}` SPEC clause tail. The suite never reads next-dev's code.
- **Additive only on the slice-1 suite. ✓** Only `tests/integration/payout-selfcheck.ts` is **M**, and that diff is **purely additive** — two `import` blocks + one new slice-2 meta-assertion section inserted before existing code; **no existing line removed or changed**. Every other file is **A** (new `_rc` siblings + new runner). Slice-1 helpers (`_spec/_assert/_flow/_stage-payout`, `probes/auth/_authctx`) are imported as-is, not mutated — slice-1's bijection + green run stay intact.
- **Fixture mutations restored in `finally`. ✓** `p004-sweep.ts` and `am5-rc.ts` capture `payout_auto_reconcile_enabled` (PAYOUT-009 isolation) and restore it in `finally`, plus `clock_reset()` and per-fixture `cleanupPayout`. The runner's outer `finally` calls `bearersDown()` + `clock_reset`.
- **No secrets in code or evidence JSON. ✓** Grep finds no hardcoded JWT/service_role/apikey/signing-key/password-credential — the hits are bearer *construction* from minted tokens (`Bearer ${si.accessToken}`), a sentinel string, and SPEC text. The committed evidence JSON (`evidence/integration-run-payout-rc-1781276546411-36403014.json`) is secret-free; it carries only the **non-secret public stack project URL** (`https://yupsev….supabase.co`), exactly as main's existing `integration-auth-*.json` / `integration-deposit-*.json` evidence files do (evidence/ is committed, not gitignored — the established house pattern).
- **Real-gotrue admin mint/teardown leaves no residue. ✓** `setupAdminBearers` mints `super_admin` + a perm-less `wrongPerm` via the gotrue admin API (+ derives aal1/forged/stub bearers for the 401 legs); `teardownAdminBearers` deletes **both** (`deleteGotrueAuthUser(s.sub)`) and is wired into the runner's `finally` via `bearersDown`. If minting fails it returns empty bearers → the EF surfaces a 401 (never a false pass).
- **Readiness gate fails loud on a bare stack. ✓** `readiness-rc.ts` distinguishes "not deployed" (REST 404 NOT_FOUND / PGRST202 schema-cache miss) from "deployed-but-auth-gated"; returns `deployed: allCore`. The runner gates money lanes on `readiness.deployed && signingKeyPresent` → otherwise **BLOCKED-ON-DEPLOY**, lanes never run, never counted green, `process.exit(1)`. Knob (R5) + RBAC-seed (R6) are correctly **soft** (fail-safe default; auth probes surface a missing grant as 403).

**Corroboration:** offline self-check **50/50** (25 slice-1 + 25 new), each predicate proven green-on-valid **and** red-on-a-violated-expectation (the load-bearing safety cases — never-auto-fail, callback-silent/freeze-held, unfreeze-touches-frozen-only, review-only producer, review→failed ≠ reverse_settle); live VERIFY **46/46 GREEN** on yupsev (evidence git_sha `3640301`), all 6 lanes.

### Non-blocking observations (#451)
- **NB-1:** in `p004-sweep.ts` the knob restore is **inline** (after the knob-tracking assert), not in `finally`; a throw between the knob bump and that line could leave the knob at `knob+10`. Benign — probes bind *relative to the knob* (next run reads it fresh) and clock+auto-reconcile *are* restored in `finally`. Symmetry nit: move the knob restore into `finally`.
- **NB-2:** the run evidence JSON is a generated artifact committed in the PR. House-consistent and secret-free (see above); flagged only for awareness (the embedded stack project-URL is a public endpoint, not a credential).
- **NB-3:** `signInPassword(…, "Pw!deposit1111")` — a shared, well-known **test-fixture** password for a throwaway gotrue identity minted+deleted within the run on a test stack, matching the existing auth-probe harness. Not a real-system credential.

---

## Cross-PR notes
- Both PRs are **DO NOT MERGE** by me; self-merge is the team's after **this APPROVE + investigator GREEN** (§9a build-code carve-out — no sealed-lane files in either PR; confirmed #449 touches no deposit-lane function).
- Minor doc nit (immaterial to verdict): the orchestrator brief cited tester git_sha `afcb9df`; the committed evidence reflects the actual run at `3640301`. The substrate the tester ran against == the current PR-head substrate (deployed==source check above), so coverage is intact regardless.
- Out of scope (untouched): #443–446 / #438 / #447 / #448 (other lanes/owners), PAYOUT-007..013, fair-router internals, merging.

## DONE-WHEN
- [x] PR #449 on-PR COMMENTED review posted (verdict in body header)
- [x] PR #451 on-PR COMMENTED review posted (verdict in body header)
- [x] this findings file
- [x] reply to the orchestrator
