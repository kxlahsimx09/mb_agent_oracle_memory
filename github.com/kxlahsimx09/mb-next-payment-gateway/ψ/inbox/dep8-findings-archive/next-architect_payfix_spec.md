# Writer Fix-Spec — epic-payout.md (campaign payfix)

**From:** next-architect · **To:** next-writer · **Date:** 2026-06-04 · **Authority:** user GO 2026-06-04 (DEC-A..E)
**ADR source (already landed, branch `arch/payfix-adr`, NOT merged):**
- §ADR-2 §S2 carve-out 2026-06-04 (DEC-A)
- §ADR-4a §Amendment 2026-06-04 — state machine + per-RPC source-state table + correction toolkit (DEC-B + DEC-D)
- §ADR-9 §Reconciliation 2026-06-04 — corrective-callback terminal flip (DEC-B / CT3)
- §ADR-10 §Amendment 2026-06-04 — `payout_reverse_settle` op + residual-MDR-to-payout + per-partner full-claw-back-or-audit-only unwind (DEC-E)
- §ADR-15 §Amendment 2026-06-04 — False-FAILED Payout Detection P2.17 (DEC-C)

> **Scope:** this file is the precise change-list for `docs/requirements/epic-payout.md`. next-architect does **not** edit the epic; next-writer applies it. Line numbers are a snapshot (epic ≈ 661 lines at authoring) — **re-verify the anchor text at HEAD before editing**, the line will have drifted. Trust = S2 (source-direct from the ratified ADR amendments above). Cite the exact §Amendment in every `Sources` block you touch.

---

## A. New / updated story numbering

Add **two** new stories (the correction toolkit, DEC-B). **Numbering — IMPORTANT:** **PAYOUT-011 is already TAKEN** — minted 2026-05-30 (INDEX.md + epic-payout revision-log) as the **deferred Phase-2 statement-driven `review → failed` auto-reconcile** surface (the §ADR-4a §Amendment 2026-05-16 RR4 direction). **Leave PAYOUT-011 untouched.** The two new correction stories take the next free numbers **012 / 013**; the PAYOUT-006 gap stays the deliberate cut. (This resolves the payreview L2 numbering-collision finding — the new stories must NOT reuse 011.)

| New story | Path | Source-state → target | Trust |
|---|---|---|---|
| **PAYOUT-012** | `correction` (the dominant CS op — 1,300×) | `failed`/`review → success` | S2 |
| **PAYOUT-013** | `reverse_settle` (false-success clawback — rarer) | `success → failed` | S2 |

Add both to the **Story shape at a glance** table (after PAYOUT-010 / after the existing PAYOUT-011 deferred entry — verify its position at HEAD) and the **Status note** (≈ line 17). Both are `gateway only`, source ADRs = §ADR-4a §Amendment 2026-06-04 · §ADR-13 D1/D2 · §ADR-10 (§Amendment 2026-06-04 for PAYOUT-013; AM2 for PAYOUT-012) · §ADR-9 (corrective callback) · §ADR-15 §Amendment 2026-06-04 (detect→remedy: P2.17→PAYOUT-012 `correction`; P2.16→PAYOUT-013 `reverse_settle`).

---

## B. DEC-D — canonical state-machine subsection + per-RPC source-state table + late-report split

**Target:** a NEW subsection in epic-payout, placed right after the **Story shape at a glance** table (≈ line 31, before `## PAYOUT-001`). Title it e.g. **"Payout state machine (canonical)"**.

**Author (verbatim-faithful to §ADR-4a §Amendment 2026-06-04 SM1/SM2/SM2-SPLIT/SM3):**
1. **States:** `pending → processing → {success | failed | review}`; `review → {success | failed}`; `pending → cancelled`. Note explicitly: **`claimed` is dropped — the work-state is `processing`** (the slash phrasing *"claimed/processing"* used throughout the epic refers to the single `processing` state); **terminal success is `success`, never `completed`**; **`review` is non-terminal** (holds the freeze, callback-silent); **`cancelled` is the pre-claim terminal**, `failed` is strictly post-claim; **no `rejected` payout terminal**.
2. **Per-RPC legal source-state table** (reproduce the SM2 table): `claim` (`pending → processing`, bot) · `mark_success` (`processing` bot / `review` admin-reconcile / `review` auto statement-matcher / **`review` LATE bot report — ACCEPTED**) · `mark_failed` (`processing` bot **ONLY**) · `mark_review` (`processing`, sweep) · `cancel`/maintenance/admin-cancel (`pending → cancelled`) · **`reverse_settle`** (`success → failed`, admin) · **`correction`** (`failed`/`review → success`, admin).
3. **Late-report split (SM2-SPLIT)** — call it out as its own paragraph: a **late bot `success` from `review` is accepted** (a late truthful success is fine — the statement just arrived slow); a **late bot `failed` from `review` is NOT accepted** — `review → failed` is the clawback case, done ONLY via admin reconcile or statement-driven reconcile, **never auto from a late bot's word** (releasing a freeze on an unverified late bot report is the dangerous case).
4. **Uniform CAS guard (SM3):** every transition RPC locks the row → asserts `status ∈ legal-source-set` → else benign no-op (lock-first-wins, the existing PAYOUT-004 race AC).

**Also reconcile existing prose** that conflicts with SM1:
- **PAYOUT-002 edge case "The stored status is `success`, not `completed`"** (≈ line 157) — keep; it already states the unify-on-`success` rule. Cross-ref the new state-machine subsection.
- Every *"`claimed`/`processing`"* phrase (≈ lines 24, 252, 275, 286) — leave the wording but ensure the new subsection clarifies it is one `processing` state (do not introduce a `claimed` row-state).

---

## C. DEC-B — the two correction stories (PAYOUT-012, PAYOUT-013)

### PAYOUT-012 — `correction` (`failed`/`review → success`) — the dominant CS op

**Author a full story** (As-a operations admin / journey / mermaid / ACs / edge cases / sources). Key content from §ADR-4a §Amendment 2026-06-04 CT1.2 + CT2:
- **Purpose:** the bank *did* pay, but the gateway recorded the payout `failed` or left it `review`. An admin corrects it to `success`.
- **Wallet branch on source state (load-bearing AC):**
  - from the **`failed` source path** — the freeze was already released to spendable, so `correction` **deducts** the client amount + fee now (re-settle the money that truly left).
  - from the **`review` source path** — the freeze was never released (held through `review`), so `correction` **settles from the held freeze with NO extra deduct** (frozen and balance each `-= amount+fee` — the normal §ADR-10 settle).
  - the RPC must read the **current** status under the SM3 lock to pick the branch; a payout that auto-reconciled out of `review` between CS-click and lock is a benign no-op (already `success`).
- **MDR fan-out** on success (the §ADR-10 success fan-out, residual rule — see §E below).
- **Callback:** enqueue `payout.success`; **corrective callback may flip a prior terminal** on the same `id` (§ADR-9 §Reconciliation 2026-06-04 — client must tolerate same-`id` terminal flip; current already does).
- **NO step-up** (DEC-A); gated by §ADR-13 D1 three-layer write + D2 canonical audit row (who/when/why) + single atomic txn + canonical lock order.
- **Detection→remedy loop:** PAYOUT-012 is the operator remedy for a P2.17 false-FAILED candidate (§ADR-15 §Amendment 2026-06-04).
- **Sources:** cite §ADR-4a §Amendment 2026-06-04 CT1.2/CT2/CT3 + §ADR-10 AM2 + §ADR-13 D1/D2 + §ADR-9 §Reconciliation 2026-06-04. Production evidence: `ConfirmPayoutCompleted` 1,300× (the dominant CS op).

### PAYOUT-013 — `reverse_settle` (`success → failed`) — false-success clawback

**Author a full story.** Key content from §ADR-4a §Amendment 2026-06-04 CT1.1 + §ADR-10 §Amendment 2026-06-04 PW1/PW3:
- **Purpose:** a payout settled to `success` but the bank in fact did not pay (false-success caught after settle, e.g. via P2.16).
- **In one txn:** flip `success → failed`; **re-credit the client** amount + fee (`payout_reverse_settle` op — `balance +=`, no re-freeze; money returns to spendable); **claw back partner MDR per-partner full-or-audit-only** (PW3 — see the explicit AC below); unwind the `is_owner` residual credit too; enqueue a **corrective `payout.failed` callback for the same `id`**.
- **NO step-up** (DEC-A); §ADR-13 D1/D2 + atomic txn + canonical lock order.
- **Detection→remedy loop:** PAYOUT-013 is the operator remedy for a P2.16 false-success candidate.
- **MDR-unwind AC (explicit; PW3, per-partner ALL-OR-NOTHING — NOT partial/best-effort).** For each partner credited at the original settle: *given* the partner wallet **can fully cover** its share, *then* the **full** share is deducted; *given* it **cannot** (already withdrew / insufficient), *then* **nothing is deducted** — the wallet is left untouched and an AUDIT row records the **full** unrecovered share as a documented shortfall (`mdr_unwind_shortfall` or equivalent). **Never a partial deduction; never a forced negative balance** (`CHECK (balance >= frozen)` never violated). The `is_owner` residual leg always covers its own unwind (no shortfall there). The whole `reverse_settle` still commits even when a partner is short — the shortfall is an auditable receivable (cleaner to net later than a partial deduct), not a blocker. (User refinement 2026-06-04: full-claw-back-if-coverable, else audit-only.)
- **Sources:** §ADR-4a §Amendment 2026-06-04 CT1.1 + §ADR-10 §Amendment 2026-06-04 PW1/PW3 + §ADR-13 D1/D2 + §ADR-9 §Reconciliation 2026-06-04. Production evidence: `OverridePayoutStatus` 239×.

---

## D. DEC-A — step-up-removal notes on PAYOUT-004 / PAYOUT-005

**Targets:**
- **PAYOUT-005** (admin manual-cancel; ≈ line 306) — Story-table row (≈ line 25) already lists §ADR-13 D1/D2 but not step-up; **add an explicit note** (edge case or AC note) that admin payout-cancel is **NOT step-up-gated** — current `VerifyTOTPStepUp` never covered payout; gated by §ADR-13 admin-write + audit only (per §ADR-2 §S2 carve-out 2026-06-04). If any AC/edge text currently implies a step-up prompt on cancel, remove it.
- **PAYOUT-004** (admin reconcile of `review`; ≈ line 240) — same: add a note that admin reconcile (`mark_success`/`mark_failed` from `review`) is **NOT step-up-gated** (per §ADR-2 §S2 carve-out). Verify no AC implies step-up.
- **PAYOUT-012 / PAYOUT-013** (new) — state up front in each that the correction is **NOT step-up-gated** (DEC-A), gated by admin-write + audit + atomic txn.
- **Sources:** in each touched story add `new:adr §ADR-2 §S2 carve-out 2026-06-04 (admin payout corrections + cancel NOT step-up-gated; current-parity — VerifyTOTPStepUp covers deposit_refund/deposit_refund_resolve only)`.

---

## E. DEC-E — MDR / residual ACs

- **PAYOUT-002 AC #4** (the success-settle AC, ≈ line 149) + **edge case "Partner MDR shares settle in the same transaction"** (≈ line 161) — **add the residual-MDR clause** (§ADR-10 §Amendment 2026-06-04 PW2, symmetric to the inflow RM rule): every profile partner produces exactly one audit row (`credit` or `mdr_skip`); an **un-creditable partner share (inactive partner / missing wallet) is credited to the `is_owner` system-residual wallet** and the `mdr_skip` row cross-references it; the payout ledger balances (`client gross-debit = client-net-cost + Σ partner-credits + residual`). This is the **"MDR fan-out in success ACs"** payreview fold-in.
- **PAYOUT-009 AC** (auto-reconcile `review → success`, ≈ line 560) — same residual clause applies (it is a named success fan-out call site, PW2).
- **PAYOUT-012** — its success path distributes MDR through the same fan-out → same residual clause.
- **PAYOUT-013** — its unwind reverses the fan-out → the **per-partner full-claw-back-or-audit-only unwind + shortfall-audit** clause (§C PAYOUT-013 / PW3).
- **Sources:** add `new:adr §ADR-10 §Amendment 2026-06-04 (PW1 payout_reverse_settle op · PW2 residual-MDR extended to payout success fan-out · PW3 per-partner full-claw-back-or-audit-only unwind + shortfall audit)` to PAYOUT-002, 009, 011, 012.

---

## F. Payreview MED/LOW fold-ins (each: target + intended change)

1. **PAYOUT-004 staleness threshold — untestable.** *Target:* journey step 2 (≈ line 251) + AC #1 (≈ line 275) *"past the sweep's staleness threshold"*. *Change:* name the threshold as an operator-tunable config knob (e.g. `payout_stuck_review_minutes`, impl-pinned) and make the AC test the **boundary relative to config** ("a payout stuck beyond the configured threshold is swept to `review`; one below it is not"), not an absolute magic number — architecturally parallel to §ADR-4d's `slip_review_timeout_minutes`. Keep "≈ once a minute" sweep cadence.
2. **PAYOUT-009 amount tolerance + grace window — untestable.** *Target:* edge case *"a small amount tolerance is expected (impl-pass pins the exact tolerance)"* (≈ line 571) + the *"bounded grace window"* phrasing (≈ lines 163, 566, 579). *Change:* name the grace window as a config knob (e.g. `payout_confirm_grace_minutes`) and frame the amount tolerance as a named bound (the bank IBFT fee posts as its own fee-classified row, so the tolerance is "fee-row-or-zero", impl-pinned) — so the AC asserts the boundary against a named knob rather than an unfalsifiable "small".
3. **MDR fan-out in success ACs.** Folded in §E above (PAYOUT-002/009 residual clause).
4. **bank_reference field.** *Target:* PAYOUT-002 journey step 3 (≈ line 122) + edge case (≈ line 160) + PAYOUT-003/004 prose that says *"bank-side transaction reference"*. *Change:* pin one canonical field name for the bank-side transaction reference (current substrate = `bank_transaction_id` on `ts_payouts`/`withdrawal_queue`; prefer that name, or `bank_reference` if the data-model pass renames it — pick one and use it consistently across PAYOUT-002/003/004). Today the prose varies ("bank-side transaction reference" vs `bank_transaction_id`); make it one term.
5. **P2.16 self-suppress.** *Target:* PAYOUT-002 edge case (≈ line 163) + PAYOUT-009 edge case (≈ line 579) that raise the P2.16 candidate-false-success alert. *Change:* add that the alert is **change-gated / self-suppressing** (bucketed dedup + heartbeat floor) so a standing candidate does not storm the channel — per §ADR-15 §Amendment 2026-06-04 FF3 (which makes P2.16 and P2.17 siblings both self-suppress). One line per edge case.
6. **rate-limit pointer.** *Target:* PAYOUT-001 — currently has **no** per-client rate-limit NFR pointer (the epic grep finds none). *Change:* add an edge case / NFR pointer that `POST /payouts` is per-client rate-limited at the edge gateway (§ADR-11 §Amendment 2026-05-26 A3 RL1–RL4, fail-open; realized at the Cloudflare edge gateway per §ADR-2 §Amendment 2026-05-28 GW1/GW7) — onboarding/operational, no new request/response field, no AC behavior change. Mirror the deposit-side pointer if one exists.
7. **bank_maintenance code enumeration.** *Target:* PAYOUT-010 (≈ line 637/642) already uses `bank_maintenance`; the gap is the **§ADR-9 `payout.cancelled` failureCode enum** not enumerating all three. *Change:* ensure the epic's PAYOUT-005/008/010 `Sources`/edge text cross-ref the canonical `payout.cancelled` code set = `{auto_cancelled` (PAYOUT-008) `· admin_cancelled` (PAYOUT-005) `· bank_maintenance` (PAYOUT-010)`}` consistently (the ADR §`payout.cancelled` codes table lists `admin_cancelled`/`auto_cancelled`; `bank_maintenance` is defined in §ADR-4a PA7 — make the epic name all three together so a tester can enumerate them).
8. **metadata bound — untestable.** *Target:* PAYOUT-001 journey step 1 (≈ line 45) + AC #1 (≈ line 67) *"bounded `metadata`"*. *Change:* name the bound (e.g. max N keys / max M bytes, impl-pinned) and reference it so the "bounded" claim is testable at the boundary, or explicitly mark it impl-pass with a named cap and an AC that an over-bound `metadata` is rejected with a structured code. Keep consistent with §ADR-9 §Amendment 2026-05-25 (metadata carries dynamic callback context).
9. **PAYOUT-011 numbering-collision (payreview L2) — RESOLVED by taking 012/013.** *Target:* INDEX.md + epic-payout revision-log + any cross-ref to `PAYOUT-011` (search epic + sibling epics). *Context:* PAYOUT-011 was already minted 2026-05-30 as the **deferred Phase-2 `review → failed` statement-driven auto-reconcile** surface (RR4 direction) — a DIFFERENT, deferred story. *Change:* **do NOT reuse PAYOUT-011** — leave it as-is (the deferred review→failed entry). The two new correction stories take **012 (`correction`) / 013 (`reverse_settle`)**. Verify the existing PAYOUT-011 entry in INDEX.md / revision-log still reads as the deferred review→failed surface and is not accidentally overwritten. Add the new detection→remedy cross-refs in the relevant edge cases: **P2.17 candidate → PAYOUT-012** (`correction`), **P2.16 candidate → PAYOUT-013** (`reverse_settle`). Distinguish clearly in prose: PAYOUT-011 (deferred, *auto* review→failed) vs PAYOUT-013 (ratified, *admin* success→failed `reverse_settle`) vs the `correction`'s review→success path (PAYOUT-012) — three different review-adjacent surfaces, do not conflate.

---

## G. Discipline reminders for the writer

- **Cite the exact §Amendment** (`§ADR-4a §Amendment 2026-06-04`, `§ADR-10 §Amendment 2026-06-04`, `§ADR-15 §Amendment 2026-06-04`, `§ADR-2 §S2 carve-out 2026-06-04`, `§ADR-9 §Reconciliation 2026-06-04`) in every `Sources` block you add or touch.
- **Do not over-generalize** a payout-scoped rule to other lanes (the §ADR-8 fair-router-scope lesson, PR #261) — these decisions are payout-lane only.
- **Terminal vocabulary:** `success` not `completed`; `processing` not `claimed`; `review` non-terminal callback-silent; no `rejected` payout terminal.
- **No step-up on any payout action** (DEC-A) — if you find step-up prose on a payout story, remove it.
- The ADR PR (`arch/payfix-adr`) is **NOT merged** — author the epic against the ADR text as landed on that branch; the user merges both.
