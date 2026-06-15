# next-tester — PAYOUT review/cancel slice-2 probe build (campaign payb2t)

> **Role / de-bias:** Step-1 PARALLEL probe build (build-workflow.md). Probes bind **EXCLUSIVELY** to
> the broadcast SPEC contract `origin/build/payout-slice2 : docs/spec/payout-review-cancel-slice.md`
> (**v1, 2026-06-12**), read via `git show` — **the contract, never next-dev's `supabase/` code**
> (layer-1 de-bias, never violated). It **EXTENDS** slice-1
> `origin/build/payout-slice1 : docs/spec/payout-core-lifecycle-slice.md` (money model §0 + state
> machine §1, read first; not restated). Expected behaviour is derived from the SPEC + the ratified
> epic/ADR text it cites (epic-payout PAYOUT-004/005; §ADR-4a D6/D7/D8 + Amendments 2026-05-16/05-18;
> §ADR-9 cancelled-codes + Reconciliation CS1/CS3; §ADR-10 AM2/AM4 + PW2 + PV1-R; §ADR-13 D1/D2;
> §ADR-2 §S2 carve-out; §ADR-20 clock).
>
> **Status: ✅ VERIFIED GREEN on the tester stack (yupsev, 2026-06-12).** Substrate deployed (brew-ops,
> items 1-6 on both stacks); SPEC re-broadcast **v2 §5.7** (exact RPC param lists). Suite ran
> **push-button → 46/46 PASS, all 6 lanes GREEN** (git_sha `3640301`). See **§7** for the run, the v2
> rebind, and the 4 probe-side fixes the live run surfaced. (Offline self-check 50/50 still gates every run.)
>
> **Branch / PR:** `test/payb2-probes` off `origin/main`. **Test-only — DO NOT MERGE** until the gates
> clear (no `supabase/` code touched; harness-only). PR #451.

---

## 0. What was built

```
tests/integration/probes/payout/         (NEW _rc modules sit alongside the merged slice-1 suite)
  _spec-rc.ts        slice-2 SPEC binding (admin EFs, sweep/mark_failed_from_review/admin_* RPCs,
                     app_settings knob, RBAC perms, outcome→HTTP maps, audit/denorm cols, seed admins)
  _assert-rc.ts      NEW pure predicates (staleByKnob, sweepTarget, reviewSilentFreezeHeld,
                     unfreezeApplied, exactlyN/exactlyOneWinner, expectedHttpForOutcome, auditRowShape,
                     isLegalSourceRc, isReconcileFailedNotReverseSettle)
  _flow-rc.ts        TRANSPORT (sweep RPC, admin-reconcile/cancel EF callers, mark_failed_from_review,
                     app_settings get/set, audit/denorm reads, real-gotrue admin bearer mint/teardown)
  _stage-rc.ts       sweep drive (backdate claimed_at relative to app_now()) + review-via-real-sweep
  p004-sweep.ts      PAYOUT-004(a) D6 sweep — 5 assertions
  p004-reconcile.ts  PAYOUT-004(b) admin reconcile success/failed/PV1-R/illegal/auth/EF-smoke — 9 assertions
  p005-cancel.ts     PAYOUT-005 admin cancel happy/non-pending/re-cancel/race/auth/EF-smoke/code-set — 8
  am5-rc.ts          AM5 walk across sweep→reconcile-success, sweep→reconcile-failed, create→cancel — 3
  sm3-rc.ts          SM3 matrix extension for the new RPCs (legal-source pins + producer-direct) — 4
  readiness-rc.ts    Lane-0 slice-2 stack-readiness gate — 17 gates
tests/integration/run-payout-rc.ts        NEW runner (reset+clock → readiness → money lanes; evidence JSON)
tests/integration/payout-selfcheck.ts     EXTENDED (+25 rc_ meta-assertions; reuses slice-1 plumbing)
```

**Reuse (house style, GOAL-directed):** the merged slice-1 helpers `_spec-payout / _assert-payout /
_flow-payout / _stage-payout` and the real-gotrue mint `probes/auth/_authctx.ts` are imported as-is —
they are my prior artifacts on `main`. The `_rc` siblings ADD the slice-2 surface without mutating the
slice-1 files (keeps slice-1's bijection + green run intact). The only slice-1 edit is the additive
`payout-selfcheck.ts` extension.

**Harness validation (offline, stack-bare):** `bun tests/integration/payout-selfcheck.ts` → **50/50
meta-assertions pass** (25 slice-1 + 25 slice-2). Every new predicate is proven **GREEN on a valid
input AND RED on a deliberately-violated one** — the load-bearing safety cases:
- a sweep `sweepTarget(processing, stale) === 'failed'` → RED (the never-auto-fail violation);
- the same row flips stale→not-stale when the knob changes → boundary tracks config, not a constant;
- a review entry that adds a callback OR releases the freeze → RED (callback-silent + freeze-held);
- an admin-cancel that **debited balance** → RED (unfreeze touches `frozen` only, AM2/AM4);
- `mark_failed_from_review` ruled legal from `processing` → RED (it is `review`-ONLY; the new producer);
- `auditRowShape` with `actor_type≠admin` → RED; `review→failed` vs `success→failed` distinguished (§3.4);
- both EF outcome→HTTP maps (raise→500, race_lost→409, not_review→409, cancelled→200) discriminate.

Also verified offline: the full 17-module graph **bundles clean** (`bun build`), and a bundler-mode
**`tsc --noEmit` is 0 errors** across every new file.

---

## 1. Probe → AC bijection

Every `ok(...)` row carries the verbatim SPEC clause it binds (the `:: …` quote tail in the detail
string). Coverage is **per the SPEC's AC surface (GOAL minimum)**; nothing is invented beyond it.

### PAYOUT-004 (a) — D6 sweep (SPEC §2.3)  — `p004-sweep.ts`

| AC (SPEC §2.3) | probe assertion |
|---|---|
| **AC#1** always-review, never auto-fail, `bank_transaction_id` NULL-or-set both land at `review` (btxn = hint only) | `p004.sweep_a_always_review_never_autofail_btxn_hint_only` (two fixtures: btxn=NULL + btxn=set) |
| **AC#2** threshold boundary **relative to the knob**; re-run after changing the knob proves config-tracking | `p004.sweep_b_threshold_split_relative_to_knob` + `p004.sweep_b2_threshold_tracks_changed_knob` |
| **AC#3** virtual-clock drivable (clock_set/clock_advance, not real time) | `p004.sweep_c_virtual_clock_drives_boundary` (fresh-at-anchor → stale after `clock_advance`) |
| **AC#4** callback-SILENT + freeze HELD + no `wallets_change_logs` row on the review flip | `p004.sweep_d_review_callback_silent_freeze_held_no_wcl` |

### PAYOUT-004 (b) — admin reconcile (SPEC §3)  — `p004-reconcile.ts`

| AC / clause | probe assertion |
|---|---|
| §3.3 **success leg**: full settle (balance ∧ frozen -= gross) + PW2 fan-out (1 row/partner, residual→mdr_owner, conservation residual≥0) + exactly-one `payout.success` + §ADR-13 audit (action=reconcile) + `last_admin_action_*` denorm + outcome=reconciled (RPC) + EF-smoke 200; AM5 | `p004.reconcile_s_success_full_settle_pw2_callback_audit_denorm` |
| §3.3/§5 **PV1-R guard** on the success path: over-allocated profile → RAISE `mdr_over_allocated`, whole reconcile rolls back, stays `review`, no settle/audit/callback (EF 500 `admin_reconcile_failed`) | `p004.reconcile_pv1r_over_allocated_raises_rolls_back_stays_review` |
| §3.3 **failed leg (delta A)** via `mark_failed_from_review`: release (frozen -= gross, **balance untouched**) + no fan-out/residual + exactly-one `payout.failed` + audit; NOT a reverse_settle (§3.4); AM5 | `p004.reconcile_f_failed_release_balance_untouched_callback_audit` |
| §5 **producer-direct** `mark_failed_from_review` (service-role) also releases + queues `payout.failed` | `p004.reconcile_fp_producer_direct_release_payout_failed` *(v2 §5.7 params; live-green)* |
| §0 **delta-A NEGATIVE**: slice-1 `mark_failed` on a `review` payout = benign no-op (processing-ONLY); the dead-leg the bug closes | `p004.reconcile_n_old_mark_failed_on_review_benign_no_op` |
| §3.2 AC#5 / §3.3 **illegal sources** (pending/processing/success/failed/cancelled) → outcome `not_review` (RPC) / 409 (EF), no money/audit/callback | `p004.reconcile_il_illegal_sources_not_review_no_effect` |
| §3.1 **auth**: no-token / aal1 / forged / stub → 401; valid aal2 lacking `payout:approve` → 403 forbidden `{required_permission}` | `p004.reconcile_a_auth_401_no_token_aal1_forged_stub_and_403_wrong_perm` |
| §3.2 **validation**: missing_payout_id / invalid_resolution / missing_reason → 400; unknown payout → 404 | `p004.reconcile_a2_validation_400s_and_404` |

### PAYOUT-005 — admin cancel (SPEC §4.4)  — `p005-cancel.ts`

| AC (SPEC §4.4 / §4.5) | probe assertion |
|---|---|
| **AC#1** happy: status→cancelled, frozen -= (amount+fee) AM2/AM4 (balance untouched), one `payout_unfreeze`, queue cancelled, one audit (action=cancel), denorm, exactly-one `payout.cancelled` code `admin_cancelled`; AM5 | `p005.cancel_h_happy_unfreeze_queue_callback_audit_denorm` |
| **AC#2** non-pending (processing/review/success/failed/cancelled) → outcome `not_pending` (RPC) / 409 (EF), no money/state/callback | `p005.cancel_np_non_pending_not_pending_no_effect` |
| **AC#3** re-cancel = benign no-op (SM3): 2nd → 409, no 2nd unfreeze/callback/audit | `p005.cancel_rc_recancel_benign_no_op_no_second_effect` |
| **AC#4** cancel-vs-claim race (lock-first-wins): claim-first → cancel 409; cancel-first → claim doesn't pick it; exactly-one winner each | `p005.cancel_r_cancel_vs_claim_lock_first_wins` |
| §4.1 **auth**: 401 (no-token/aal1/forged/stub) + 403 (lacking `payout:cancel`); validation 400s + 404 | `p005.cancel_a_auth_*` + `p005.cancel_a2_validation_400s_and_404` |
| **§4.5** failure-code set (admin_cancelled in-scope; auto_cancelled/bank_maintenance enumerated) | `p005.cancel_c_failure_code_set_admin_cancelled_in_scope` |

### Cross-cutting

| GOAL clause | probe |
|---|---|
| AM5 walk across **sweep→reconcile-success**, **sweep→reconcile-failed**, **create→cancel** | `am5rc.sweep_reconcile_success_*`, `am5rc.sweep_reconcile_failed_*`, `am5rc.create_cancel_*` (review produced by the **real** D6 sweep, end-to-end) |
| **SM3 matrix extension** for the new RPCs | `sm3rc.legal_map_*` (3 pins) + `sm3rc.mark_failed_from_review_illegal_sources_benign_no_op` |
| §3.4 boundary: `review→failed` ≠ PAYOUT-013 `reverse_settle` (`success→failed`) | bound in `reconcile_f` (`notReverseSettle`) + selfcheck `rc_reconcile_failed_not_reverse_settle` |

---

## 2. Stack-needs delta (PENDING-DEPLOY — for brew-ops/owner cross-stack deploy)

The slice-2 substrate must land on the **tester** stack before any money probe runs (Stack-readiness
gate). `readiness-rc.ts` (Lane-0) asserts all of this; on a bare stack it goes RED → money lanes report
**BLOCKED-ON-DEPLOY** and never run. Exact delta vs the slice-1 deploy:

**Edge Functions (respond, not 404):**
- `admin-payout-reconcile` (POST; real gotrue JWT + aal2 + RBAC `payout:approve`)
- `admin-payout-cancel` (POST; real gotrue JWT + aal2 + RBAC `payout:cancel`)

**RPCs (present, service-role-callable):**
- `sweep_stale_claims(p_batch_size int DEFAULT 500, p_now timestamptz DEFAULT NULL)` — SECURITY DEFINER, `GRANT EXECUTE … TO service_role`, reads `app_now()` (not `now()`)
- `mark_failed_from_review(uuid, text, text)` — the new sanctioned `review→failed` producer (delta A)
- `admin_reconcile_payout(…)` / `admin_cancel_payout(…)` — the EF-delegated RPCs (param names unpinned, see §3)
- `cancel_stale_payout(payout_id, failure_code)` — the atomic pending→cancelled step
- `_payout_stuck_review_minutes()` — the knob reader (fail-safe default 5)
- carried/required: `mark_review`, `mark_success`, `claim_withdrawal_items`, `mark_failed`, `clock_set`/`clock_advance`/`clock_reset`/`app_now`, `reset_for_test`

**Tables / config seed:**
- `app_settings` rows: `payout_stuck_review_minutes` (default 5) **and** `payout_auto_reconcile_enabled` (the probe sets it `false` during PAYOUT-004 for PAYOUT-009 isolation, then restores; the row must exist to read/restore)
- `audit_log` present (entity=payout writes; §ADR-13 D2)
- `ts_payouts` carries the `last_admin_action_*` denorm columns + the AFTER-INSERT trigger
- the §ADR-13 **RBAC grant seed**: `super_admin ⊇ {payout:approve, payout:cancel}` (and a perm-less role e.g. `partner_user` for the 403 negative). **If this grant is not seeded, super_admin → 403 and ALL money lanes block** — surfaced by `readiness-rc R6` + the auth probes.

**Tester slot env (brew-ops provisioning):**
- `GATEWAY_ASSERTION_SIGNING_KEY` + `GATEWAY_ASSERTION_KID` (scope=payout GW4 keypair) — needed by the **create staging** (slice-1 dependency; the admin auth itself is real gotrue, minted by the harness via the gotrue admin API).

> **Do not run money probes against any stack until the owner signals stack-ready.** A bare stack is a
> BLOCKER I surface here, not a green and not an idle (build-workflow.md).

---

## 3. SPEC bindings — all RESOLVED (v2 §5.7) + verified over the wire

The suite is **BOUND** (`SPEC_RC_UNBOUND = false`). Every v1 `[SPEC-PENDING]` RPC-param guess was
**resolved by SPEC v2 §5.7** and the audit-column shapes were corrected against the deployed schema
during the live run:

1. **`mark_failed_from_review`** — v2 §5.7 PINNED `(p_queue_id, p_error_message, p_failure_code DEFAULT
   'system_error')`. The v1 `p_reason` guess was **wrong** (orchestrator-flagged); rebound. ✅ green.
2. **`admin_reconcile_payout`** — v2 §5.7 PINNED `(p_payout_id, p_resolution, p_actor_id,
   p_actor_username, p_reason, p_bank_transaction_id?)` → jsonb `{outcome, resolution, audit_id}`.
   Now the **DIRECT money path** (SPEC §5; gotrue-independent). ✅ green.
3. **`admin_cancel_payout`** — v2 §5.7 PINNED `(p_payout_id, p_actor_id, p_actor_username, p_reason)`
   → jsonb `{outcome, status, audit_id}`. DIRECT money path. ✅ green.
4. **`audit_log` columns** — REBOUND to the deployed schema (verified over the wire): `resource_type`
   (='payout'), `action_type` (='reconcile'|'cancel'), `metadata` (jsonb detail), `resource_id`
   (=payout_id); `actor_type`/`actor_id`/`actor_username`/`reason` were already correct. ✅ green.
5. **`ts_payouts.last_admin_action_*` denorm** — present on the deployed schema
   (`last_admin_action_type`/`_by`/`_at`/`_reason`); the denorm check matches any `/last_admin_action/`
   column. ✅ green.
6. **RBAC grant seed** — `super_admin ⊇ {payout:approve, payout:cancel}` IS seeded: the EF wiring
   smokes (`reconcile_ef`, `cancel_ef`) returned **200** via a real aal2 super_admin (not 403), and the
   `partner_user` actor correctly got **403** `{required_permission}`. ✅ green.

→ **Nothing left routed.** All param/column bindings are pinned and live-verified. (The DIRECT-RPC
money path is now the primary; the EF adds the auth gate + a wiring smoke — SPEC §5 split.)

---

## 4. Decisions (named, per GOAL)

- **New `_rc` sibling modules** rather than mutating the merged slice-1 helpers — keeps slice-1's
  bijection + verified-green run untouched; the slice-2 binding block is self-contained and traceable
  to the slice-2 SPEC. Only `payout-selfcheck.ts` is edited (additive).
- **Runner = `run-payout-rc.ts`** (a new runner, NOT an extension of `run-payout-core.ts`) — keeps the
  slice-1 push-button gate independent and lets the slice-2 lanes/evidence file stand alone.
- **SPEC §5 split after v2 (the PRIMARY design):** MONEY logic via the **DIRECT service-role RPC**
  (gotrue-independent — passes `p_actor_id` from the pre-seeded super_admin `app_user`), the **EF adds
  the 401/403 auth gate + a happy-path wiring smoke**. This decouples money correctness from the gotrue
  mint (ITEM-7 AMBER) and the RBAC grant — both are exercised by the EF legs, but a hiccup there cannot
  mask a money bug. *(v1 drove money via the EF to avoid guessing RPC params; v2 §5.7 pinned them, so
  the SPEC-intended direct path is now both available and more robust.)*
- **`review` staged two ways:** isolated probes force `review` (slice-1 `stageAt`); the AM5 walk uses
  the **real D6 sweep** so the sweep→reconcile lifecycle is genuinely end-to-end.
- **Sweep/race staging = the SPEC §5 claim-path-INDEPENDENT drive** (force `ts→processing` + `wq→claimed`
  + backdated `claimed_at`), so multiple stuck rows seed on one fixture bank without tripping slice-1's
  "one batch per bank" claim constraint.

---

## 5. Isolation / out-of-scope (per SPEC §5 + GOAL)

- **PAYOUT-009 (statement-auto-reconcile) fixture-isolated:** the sweep + AM5 probes set
  `app_settings.payout_auto_reconcile_enabled='false'` (and restore it in `finally`) so the
  `mark_review` tail cannot auto-resolve `review→success` in the sweep tick (out of slice, SPEC §5).
- **Out of scope (not probed):** PAYOUT-007..013 (resend, auto-cancel, statement-reconcile, per-bank
  maintenance, correction/reverse_settle), bot dispatch / fair-router internals; the §3.4 boundary is
  asserted only as a *distinction* (review→failed ≠ reverse_settle), not as PAYOUT-013 coverage.
- **SPEC AC#5 (cancel atomic rollback)** is structurally covered by the happy-path all-or-nothing
  observation; a forced mid-txn failure is not black-box-injectable without reading/altering code
  (de-bias) — noted, not faked.
- **IP-allowlist** (named in the §3.1/§4.1 auth chain) is **not** in the GOAL's negative set (no-token /
  aal1 / wrong-perm). The harness seeds an empty allowlist (allow-all) so it does not block the happy
  path; a wrong-IP negative is a later add if the contract asks for it.

---

## 6. DONE-WHEN status

- [x] Probe suite authored (3 core probes + AM5 walk + SM3 matrix + readiness + runner)
- [x] Harness-validated offline (selfcheck 50/50; bundle clean; tsc 0 errors)
- [x] Committed on `test/payb2-probes` off `origin/main`
- [x] Probe→AC bijection (§1) + stack-needs list (§2) in this file
- [x] ONE PR open (test-only, **DO NOT MERGE** until gates clear) — PR #451
- [x] **VERIFY run GREEN on yupsev — 46/46, all 6 lanes (§7)**
- [ ] next-investigator L2 ground-truth falsification (own seal stack) → then review-gate → DONE (not mine)

---

## 7. VERIFY run (yupsev, 2026-06-12) — ✅ GREEN 46/46

`set -a; source .secrets/slots/tester.env; set +a; bun tests/integration/run-payout-rc.ts`
→ **GREEN, 46/46 passed**, git_sha `3640301`, evidence
`evidence/integration-run-payout-rc-1781276546411-36403014.json`.

| lane | result |
|---|---|
| lane0-readiness | GREEN (17/17 — tables/EFs/RPCs/clock/knob; soft R6 RBAC-seed note only) |
| lane1-sweep | GREEN 5/5 (always-review, btxn-hint, threshold-relative-to-knob, knob-tracking, virtual-clock) |
| lane2-reconcile | GREEN 9/9 (success+PW2+audit+denorm, PV1-R raise, failed/release, producer-direct, delta-A negative, illegal sources, EF smoke 200, auth 401/403, validation) |
| lane3-cancel | GREEN 8/8 (happy unfreeze+audit+denorm, code-set, non-pending, re-cancel, race lock-first-wins, EF smoke 200, auth 401/403, validation) |
| lane4-am5 | GREEN 3/3 (sweep→reconcile-success, sweep→reconcile-failed, create→cancel) |
| lane5-sm3 | GREEN 4/4 (legal-source pins + mark_failed_from_review illegal-source benign-no-op) |

**Live-confirmed money facts (ground truth):** PV1-R RAISEs `mdr_over_allocated` and rolls back
(stays review, freeze intact); reconcile-success settles + fans out PW2 conserving to the fee; the
delta-A bug is closed (new `mark_failed_from_review` releases + callbacks; old `mark_failed` is a
benign no-op on review); admin-cancel unfreezes without touching balance; audit `actor_id` =
`probe-admin` (88888888…001), `resource_type=payout`, correct `action_type` + `metadata`.

### Probe-side fixes the live run surfaced (mine; reported + fixed, code-blind)

1. **audit_log column rebind** — deployed schema is `resource_type`/`action_type`/`metadata`/`resource_id`
   (not `entity`/`action`/`detail`); rebound in `_spec-rc`. (The v1 [SPEC-PENDING] note predicted this.)
2. **sweep/race staging** — switched from the real claim to the SPEC §5 claim-path-independent drive;
   the real claim's "one batch per bank" blocked seeding multiple stuck rows on one fixture bank
   (symptom: 2nd+ rows stayed `pending`/`processing`, never swept).
3. **cancel-vs-claim race** — rewrote to a genuine concurrent `Promise.all` (exactly-one-winner, either
   lock order acceptable) + a deterministic cancel-first leg (cancelled is strictly pre-claim) — the
   prior claim-first ordering was fragile against leftover bank batches.
4. **readiness** — dropped the `mark_review` arity soft-check (not pinned in v2 §5.7; presence proven
   transitively by the sweep producing `review`).

### ITEM-7 (gotrue admin seed) — resolved by the harness

`auth.users=0` on yupsev → the harness mints its own gotrue super_admin + a perm-less `partner_user`
via the admin API (TOTP enroll → aal2; the auth-probes pattern), so the EF gate legs ran for real
(401 ×4 / 403 with `required_permission`). The DIRECT money legs used the pre-seeded `probe-admin`
`app_user` as `p_actor_id` (gotrue-independent), per the orchestrator's note.

> Per the build-workflow, this GREEN is the tester's VERIFY layer; it is not a seal. next-investigator
> independently falsifies every PASS against the truth DB on its own seal stack (run git-sha = merged
> HEAD) before any seal.
