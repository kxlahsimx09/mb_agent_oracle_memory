# next-pm — PAYOUT slice-2 Step-4 MARK — findings + handoff

**Campaign:** payb2pm · **Branch:** `campaign/payb2pm` (off `origin/main` @ `b97bbac`) · **Date:** 2026-06-12
**Role:** build-workflow **Step-4 MARK** (next-pm). Doc-only DoD mark of the slice-2 stories; **not** an epic seal.
**Stories marked:** PAYOUT-004 (stuck-claim sweep → `review` + admin reconcile) · PAYOUT-005 (admin-cancel of a `pending` payout)

---

## 1. TL;DR

Marked **PAYOUT-004 / PAYOUT-005** as **slice-DoD-done** in `docs/requirements/epic-payout.md` using the **same in-slice-done-NOT-epic-done green-dot pattern** I established for slice-1 (the parallel-open **#448**), and recorded the slice-2 entry in `docs/requirements/epic-payout-revision-log.md`. **The payout EPIC stays NOT-done** — per §ADR-21 **G2** it still owes a `next-investigator` epic-seal AND the §ADR-21 LIVE signoff; neither has run. **Doc-only, additive (+27 / −0).** ONE PR off `origin/main`, **DO NOT MERGE** (reviewer + owner gate). Every gate independently verified at HEAD before marking.

---

## 2. Verification at HEAD (`origin/main` `b97bbac`, `git fetch` first) — all 6 items GREEN

| # | Item | Verdict | Evidence |
|---|---|---|---|
| 1 | **PR #449 MERGED** (build) | ✅ | merge `aae0f77`, `2026-06-12T15:26Z`, `build/payout-slice2`→`main`. At `origin/main`: migrations `20260612000130_payout004_reconcile_failed_from_review.sql` + `…000140_payout004_sweep_appnow_config.sql` present; 2 comment-only EF headers (`admin-payout-cancel`/`admin-payout-reconcile`). |
| 2 | **PR #451 MERGED** (probes) | ✅ | merge `b97bbac`, `2026-06-12T15:26Z`, `test/payb2-probes`→`main`. `tests/integration/probes/payout/{_spec,_assert,_flow,_stage}-rc.ts`, `p004-sweep`, `p004-reconcile`, `p005-cancel`, `am5-rc`, `sm3-rc`, `readiness-rc` + `run-payout-rc.ts` present at HEAD. |
| 3 | **Tester VERIFY 46/46 GREEN, 6 lanes, `yupsev`** | ✅ | evidence `evidence/integration-run-payout-rc-1781276546411-36403014.json` **committed at HEAD** (22 560 bytes); `wt-c-payb2t/next-tester_payb2t_findings.md` §7; `git_sha 3640301` (the later cosmetic v1→v2 label commit — immaterial; binds the SPEC). |
| 4 | **Investigator falsification 65/65 GREEN (+1 teeth-sentinel RED), `qnccph`** | ✅ | `wt-c-payb2i/next-investigator_payb2i_findings.md` (VERDICT GREEN; independent re-derivation in `BEGIN … ROLLBACK`, zero-footprint, every PASS attacked, 46/46 corroborated-not-inherited); ψ envelope `…/ψ/inbox/for-orchestrator/2026-06-12_22-30_from-next-investigator_payb2_verdict-payout-slice2-falsification-GREEN.md`. |
| 5 | **Reviewer APPROVE ×2 on-PR** | ✅ | #449 + #451 **body-header** verdicts ("✅ APPROVE — next-code-reviewer", Step-3 payb2r). gh review state stays `COMMENTED` per the self-approve refusal (expected — same as slice-1). |
| 6 | **SPEC v2 on main via #449** | ✅ | `docs/spec/payout-review-cancel-slice.md` present at `origin/main`. |

**Marked off the same HEAD I verified — no race between verify and mark.**

---

## 3. What I changed (doc-only, +27 / −0)

**`docs/requirements/epic-payout.md` (+19):**
- `### Slice-2 build status (DoD)` evidence block (under "Story shape at a glance", same anchor location as slice-1's block) — the green-dot `🟢 Slice-2 = DoD-GREEN … In-slice-done, NOT epic-done` header + the full BUILD/PROBES/VERIFY/FALSIFY/REVIEW evidence chain.
- Per-story `🟢 Slice-2 build: DoD-GREEN` markers on **PAYOUT-004** and **PAYOUT-005** (after each `**[S2 ratified]**` line).
- A `🟢 Slice-2 build` marker on the **Payout state machine (canonical)** subsection — the now-LIVE `review → failed` admin-reconcile edge (drift-A realized), SM2-SPLIT preserved.

**`docs/requirements/epic-payout-revision-log.md` (+8):** the 2026-06-12 slice-2 entry (newest-first) — the DoD mark, evidence verified at `b97bbac`, the **drift-A closure** narrative, and the **3 dev-routed non-blocking observations**.

**No story trust label changed (all stay S2). INDEX.md untouched** (trust-label surface; build/DoD state lives in the epic — slice-1 + deposit precedent). No `adr.md`, no code, no spec edits.

---

## 4. Drift-A closure (recorded in the revision log + the SM marker)

The **dead reconcile-failed leg.** Before slice-2, `admin_reconcile_payout`'s failed leg delegated to slice-1 `mark_failed`, which slice-1's **SM2-SPLIT** narrowed to **`processing`-ONLY**. So an admin marking a `review` payout `failed` hit a **silent benign no-op** — freeze never released, no `payout.failed` callback, payout stuck at `review` (PAYOUT-004 AC#4 broken). **A `review` payout could never fail/release by any sanctioned path.** Slice-2's `mark_failed_from_review(uuid,text,text)` is the sanctioned `review → failed` producer (own `review`-source CAS, AM2 release with balance untouched, byte-identical `payout.failed` callback, `failure_code` default `system_error`); `admin_reconcile_payout`'s failed leg is re-pointed to it. **Distinct from** `mark_failed` (stays `processing`-only — dangerous late-bot path stays locked out, SM2-SPLIT preserved) and PAYOUT-013 `reverse_settle`. PV1-R `mdr_over_allocated` fail-close inherited on the success leg.

---

## 5. The 3 routed non-blocking observations (recorded; not fixed here)

1. **Claim-path `claimed_at = now()` T1 residue** — `claim_withdrawal_items` (`20260520000002`) stamps wall-clock `now()` not `app_now()`. Bot-lane, out of slice; sweep is drivable without it. → **next-architect / PAYOUT-002 (bot-lane) owner.**
2. **Deposit admin EFs carry the same stale "JWT (stub)" comment** (`admin-deposit`, `admin-deposit-resolve`, `admin-deposit-verify-now`) — cosmetic JWT-FLIP residue, DEPOSIT lane. → **deposit-lane owner.**
3. **`mark_review` lacks a positive `processing`-source assert** (only the `status='review'` idempotency early-return). Money-safe today (sweep predicate constrains the source); robustness nit. → **next-architect (optional).**

---

## 6. Coordination — parallel-open slice-1 mark #448 (merge note for owner/reviewer)

I branched off **`origin/main`** as instructed. The **slice-1** PM mark is the parallel-open **#448** (`campaign/payb1pm`, also off main, also DO-NOT-MERGE) — its Slice-1 block / SM marker / revision-log entry are **not** on main yet. Both PRs therefore add a build-status block at the same anchor, an SM-section blockquote, and a `## 2026-06` revision-log entry. **On merge the owner keeps BOTH** (house **merge-not-rebase, keep-both** rule): in the epic, Slice-1 block then Slice-2 block (chronological top-to-bottom); in the revision log, Slice-2 entry above Slice-1 (newest-first). The conflicts are trivial, additive, and expected. No rebase. (#447 — the test-index canonical-rows PR — is a separate surface, not touched here.)

---

## 7. Status / DONE-WHEN

- ✅ Epic marks (PAYOUT-004 + PAYOUT-005 + SM edge) applied.
- ✅ Revision-log entry (drift-A closure + 3 routed observations) applied.
- ✅ ONE docs PR open off `origin/main` — **DO NOT MERGE** (reviewer/owner gate).
- ✅ Findings = this file.
- **Epic stays NOT-done** (out of scope: epic-seal, LIVE signoff, PAYOUT-007..013, merging, code).

**Next:** `next-code-reviewer` reviews this docs PR on-PR (gate); owner merges this + #448 together (keep-both). Then the epic still owes the §ADR-21 G2 epic-seal + LIVE signoff before payout is epic-DONE.
