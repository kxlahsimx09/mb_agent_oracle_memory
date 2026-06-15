# next-code-reviewer — PAYOUT slice 5 (FINAL, campaign payb5r) findings

**Campaign:** payb5r · **Worktree/branch:** `mb-next-payment-gateway.wt-c-payb5r` (`campaign/payb5r`) · **Date:** 2026-06-13 · **Reviewer slot:** next-code-reviewer
**PRs under review:** **#477** (build — migration `20260613000010` + 3 greenfield RPCs + 2 EFs + config.toml) · **#478** (test-only — `_ct` probe suite + `run-payout-ct.ts`)
**SPEC (v1):** `origin/build/payout-slice5 : docs/spec/payout-correction-toolkit-slice.md`
**Step-3 three-dimension review:** requirement / clean-code / perf.

## VERDICT — BOTH **APPROVE (COMMENTED)**.  DO NOT MERGE (reviewer verdict → orchestrator; self-merge only after my APPROVE **AND** investigator GREEN, per house rules).

---

## PR #477 (build) — APPROVE

### (0) CRITICAL cross-boundary seal — **HELD** (the one BLOCKING gate; passed)
Grepped the **authoritative** PR diff (`gh pr diff 477`, not the stale-local 3-dot). The migration `20260613000010` contains **only**:
- 3 × `CREATE OR REPLACE FUNCTION` — `mdr_clawback_fanout`, `admin_correct_payout`, `admin_reverse_settle_payout` (all greenfield; census-confirmed ABSENT at HEAD).
- 3 × `REVOKE ALL … FROM PUBLIC` + 3 × `GRANT EXECUTE … TO service_role`.

**No `mark_success` / `match_payout_statement` / forward-fan-out redefinition. No `DROP FUNCTION`, no `ALTER FUNCTION`, no `CREATE OR REPLACE VIEW`.** Every `mark_success`/`match_payout_statement` token in the diff is in docs/comments or a string literal inside the clawback query (`operation = 'mdr_distribute'`). **Slice-1 / bbot seal intact** — `mark_success` is reused via `PERFORM`, `reverse_settle` reconstructs from its change-log rows.

### (1) Requirement conformance
- **PAYOUT-012 correction — source-state-dependent client leg correct for BOTH sources.**
  - `review` → `PERFORM mark_success(queue,btxn)` directly → settle-from-held-freeze (`balance −gross AND frozen −gross`), one `payout_settle`. ✓ (§2.1/§3.4 AC#2)
  - `failed` → **pre-freeze** (`frozen += gross`, one `payout_freeze` row) → transient `status := 'review'` (same-txn, never committed-visible) → `PERFORM mark_success` → re-freeze+settle **net to a pure re-debit** (`balance −gross`, `frozen` unchanged). The **PRE-freeze ordering respects `wallet_frozen_nonneg (frozen ≥ 0)`** (never reconstructs frozen after dipping). ✓ (§2.1/§3.3/AC#1)
  - **Success leg delegates to `mark_success` VERBATIM** — settle/PW2/residual/PV1-R `mdr_over_allocated` fail-close/one-callback are **not reimplemented**. ✓
  - Lock-set pre-acquire in the failed branch (`client + current-profile partners + mdr_owner`, `ORDER BY id ASC FOR UPDATE`) = the exact set `mark_success` re-locks ⇒ no in-tier inversion, no deadlock. ✓
- **PAYOUT-013 reverse_settle + `mdr_clawback_fanout`.**
  - PW1 client re-credit `balance += gross`, **frozen unchanged** (no re-freeze), one `payout_reverse_settle`. Unconditionally AM5-safe. ✓
  - Per-partner **full-clawback-or-audit-only-shortfall**: floor `(balance − net_share) >= frozen` → coverable deducts the full `net_share` + one `mdr_clawback`; uncoverable deducts **nothing** + one `mdr_unwind_shortfall` (full share). **Partner NEVER forced negative** — verified the floor is the post-deduct `balance ≥ frozen` invariant; the `>=` boundary (`balance−share == frozen`) correctly clawbacks. ✓ (§2.2/CB4)
  - **CB3 reconstruct-from-recorded-amounts (no re-rounding)** — netting by `reference_id` over the change-log, reverses the *recorded* shares. ✓
  - **CB5 reverse-conservation by construction**: each forward credit maps to exactly one full reverse row (clawback xor shortfall) + residual unwound ⇒ `Σ clawback + Σ shortfall + residual_unwound = payout_fee` (single-generation). ✓
  - One reverse row per partner; `mdr_skip` partners (no `mdr_distribute`) produce no leg (unwound via residual). ✓
  - **Commits on shortfall (PW3)** — shortfall is a plain audit INSERT, no RAISE; only a non-shortfall load-bearing failure rolls back. ✓
  - Corrective `payout.failed` callback: own `event_id = gen_random_uuid()` + **explicit unique** `dedup_key = 'payout:'||id||':payout.failed:'||audit_id` (audit written first). Never suppressed by a prior terminal. ✓ (CT3/§7)
- **SM3 legal-source guards** — `correction ∈ {failed,review}`, `reverse_settle = {success}`, else **benign no-op** (`not_correctable` / `not_success` with zero money/callback/audit). **Lock-first**: `FOR UPDATE` queue→payout, status read under the lock (CT2 — an auto-reconcile race that beat the lock is already `success` → no-op). ✓ (§5)
- **NOT step-up-gated** — neither RPC nor EF references any step-up module; EFs import only `adminAuth/requirePermission/isAuthError` + `rpc/json`. §ADR-2 §S2 carve-out, current-parity. ✓
- **SV8 grants** — all 3 fns `REVOKE ALL FROM PUBLIC` + `GRANT EXECUTE TO service_role` only; **no PUBLIC/anon/authenticated**. `SECURITY DEFINER` + `SET search_path = public` on all 3. ✓
- **config.toml** — `[functions.admin-payout-correct]` + `[functions.admin-payout-reverse-settle]` both `verify_jwt = false`, alongside the sibling `admin-payout-reconcile` (same EF-owns-its-auth pattern). Verified the new EFs' `adminAuth → isAuthError → requirePermission("payout:approve")` chain is shape-identical to the sealed sibling. ✓
- **Migration safety** — forward-only (`…000010` sorts after the prior HEAD `20260612000260`), `CREATE OR REPLACE` is idempotent/re-runnable, filename unique (no collision on `main`). ✓

### (2) Clean-code
- Heavily and accurately commented; follows the slice-2 §ADR-13 admin-write envelope. EFs are thin HTTP shells (outcome→HTTP switch matches §3.2/§4.2 exactly, incl. the `default → 500 *_unexpected_outcome`). 
- Minor (non-blocking): the `wallets_change_logs` INSERT block recurs 5× across the two RPCs; plpgsql ergonomics + existing codebase style inline these — fine to leave. The lock-set `UNION` subquery appears in both RPCs but with an **intentional** semantic difference (correct = current-profile partners; reverse = historical change-log wallets, CB3) — not duplication to extract.

### (3) Perf
- Admin-triggered, low-frequency CS ops — not a hot path. `mdr_clawback_fanout` does one `GROUP BY` over `wallets_change_logs` filtered by `(reference_type, reference_id)` (tiny per-payout cardinality, same access pattern the forward fan-out already uses) + a per-partner loop bounded by the profile's partner count. No N+1, no unbounded scan, no concern.

### §6/§8 architect notes — assessed, **all NON-BLOCKING (agree)**
- **§8-A** failed-path client insufficiency → fail-closed re-freeze RAISE (`wallet_balance_gte_frozen`) → whole rollback, payout stays `failed`. **Agree** — safe default, never force-negative; architect to confirm fail-closed vs audit-shortfall. (Probe P012-4 covers it.)
- **§8-B** multi-generation netting. **Agree non-blocking — and note a positive divergence:** the migration nets `Σ mdr_distribute − Σ mdr_clawback − **Σ mdr_unwind_shortfall**` (3-term), which is *stricter / more correct* than the literal SPEC §4.4/§8-B text (`Σ distribute − Σ clawback`, 2-term). The 3-term form makes a prior shortfall **consume its distribute generation** (receivable-aware → no double-claw on a re-correction). Single-generation-identical (the only Phase-1-probed case). **Recommend the architect's §8-B confirmation explicitly ratify the 3-term form** the impl ships.
- **§8-C** corrective-callback dedup collision on **repeat-success**. **Agree non-blocking.** A *second* success via re-correction would hit `mark_success`'s static `dedup_key = payout:<id>:payout.success` → UNIQUE violation → **fail-safe rollback** (500, payout keeps prior status). That is *safe* (no corruption / no double money move), merely can't repeat-correct-to-success without an architect-gated `mark_success` touch (sealed). Dominant single-correction works. Correctly classified.
- **§8-D** `reverse_settle` failure_code taxonomy — column `NULL` + payload `failureCode='admin_reverse_settle'`. **Agree** — identical established pattern to slice-3 `bank_maintenance`; shared-CHECK add is architect-routed, out of slice.
- Tiny observation (non-issue): the residual leg has no explicit coverable check (relies on "platform-owned always covers"); were it ever false, `wallet_balance_gte_frozen` fails-closed (rollback) — safe, matches the PW3 ratified assumption.

---

## PR #478 (test-only) — APPROVE

- **SPEC-not-impl binding** — every probe header cites the SPEC §; suite is read off `origin/build/payout-slice5:…` via `git show`, **never** `supabase/` (de-bias layer-1). The pure predicates in `_assert-ct.ts` encode the SPEC money rules and exactly mirror the migration (e.g. `clawbackDecision` floor `round2(balance−netShare)+0.005 >= round2(frozen)` ≡ the RPC's `(balance − net_share) >= frozen`; `correctionClientLeg` encodes CT1.2 per source). ✓
- **Additive `_ct` siblings** — 11 new `_ct`/probe files + `run-payout-ct.ts`. The **only** pre-existing file touched is `payout-selfcheck.ts`, and that change is **purely additive (141 added / 0 removed)** — the named selfcheck extension (+29 slice-5 meta-assertions → 149/149). No slice-1..4 probe mutated. ✓
- **Fixture restoration in `finally`** — runner `finally` tears down minted bearers (`deleteGotrueAuthUser ×2`) + `clock_reset`; each probe `finally` runs `cleanupPayout` per staged payout + `clock_reset`. Clock / identities / payouts restored. Minor (non-blocking): the partner-wallet drain in the shortfall leg isn't explicitly re-credited in `finally`, but `reset_for_test` at run-start + no cross-probe dependency on the post-drain balance make this benign. ✓
- **No secrets** — real-secret sweep over both diffs clean; the only password literal is the **pre-existing** test fixture `Pw!deposit1111` (already on `main` in `_authctx.ts`/`_flow-rc.ts`/`_flow-rr.ts`). ✓
- **`readiness-ct` fails loud** — a RED stack gate → money lanes report `BLOCKED-ON-DEPLOY`, never run, never count green; the runner exits non-zero on UNBOUND / BLOCKED / any failure. A bare stack is never green. ✓
- **Evidence JSON clean** — `evidence/integration-run-payout-ct-1781338922737-2e65dce9.json`: `status: GREEN`, `summary 54/54`, all 5 lanes GREEN (readiness 25/25 implied · ct-efgate 18/18 · correction 4/4 · reverse 3/3 · sm3 4/4) on tester stack `yupsev`. No secrets in the artifact. ✓
- **Money-load-bearing rigor** — reverse-conservation asserted with **two independent witnesses** (RPC return AND wcl reconstruction) to the **satang** (`moneyEq` half-satang tolerance → a 1-satang break is RED); shortfall victim asserted UNTOUCHED (never forced-negative); the §6 bare-success teeth proves the conservation witness *requires* a real settle. ✓

**Verdict:** independent VERIFY gate confirmed; APPROVE. DO NOT MERGE.

---

## Disposition
- Posted COMMENTED reviews on #477 and #478 (verdict in body header).
- Both **APPROVE**. No blocking findings. Cross-boundary seal **HELD** (the BLOCKING gate). All four §8 architect notes are correctly non-blocking; one positive note for the architect (§8-B impl ships the stricter receivable-aware 3-term netting — ratify it).
- House rules honored: **I did not merge.** Self-merge is gated on my APPROVE **AND** investigator GREEN + owner gate. Out-of-scope (untouched): merging, other PRs, the epic-seal.
