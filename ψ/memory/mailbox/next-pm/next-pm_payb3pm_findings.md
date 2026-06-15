# ✅ next-pm — PAYOUT slice-3 Step-4 MARK — DONE (doc-only, PR open, NOT merged)

**Campaign:** payb3pm · **Branch:** `campaign/payb3pm` (wt-c-payb3pm) · **Base:** `origin/main` `26e34ac` · **Date:** 2026-06-13
**Scope:** Mark **PAYOUT-008** + **PAYOUT-010** slice-DoD-done in `docs/requirements/epic-payout.md` using the established
**in-slice-done-NOT-epic-done** green-dot pattern; record the closures + design decisions + routed residue in the revision log.
**Out of scope (untouched):** epic-done / epic-seal · PAYOUT-007/009/012/013 · merging · code.

---

## 0. Verdict

**MARK COMPLETE.** Slice-3 is **DoD-GREEN, in-slice-done, NOT epic-done.** The payout **EPIC stays NOT-done** —
per §ADR-21 **G2**, epic-DONE owes BOTH a `next-investigator` **epic-seal** AND the §ADR-21 **LIVE signoff**; neither
has run. This pass records a build/verify state against already-ratified requirement text — **no behavior change, no
trust label changed, INDEX.md untouched.** One docs-only PR is **OPEN off `origin/main` and NOT merged** (per GOAL).

---

## 1. Evidence — every item verified at HEAD `origin/main` `26e34ac` (git fetch, 2026-06-13) BEFORE marking

| # | Item | Verified | How |
|---|---|---|---|
| 1 | **PR #457 MERGED** (build, RPC-only, no EFs) | ✅ | `gh pr view 457` → MERGED 2026-06-12T18:20Z, merge `84ad622`; migrations `20260612000160_payout008_sweep_appnow` + `…000170_payout010_bank_maintenance_sweep` present on `origin/main` (`git ls-tree`); reviewer confirmed scope = docs + 2 migrations only |
| 2 | **PR #458 MERGED** (probes) | ✅ | `gh pr view 458` → MERGED 2026-06-13T00:03Z, merge `26e34ac` (= HEAD); `tests/integration/run-payout-cs.ts` + `_cs` modules + `payout-selfcheck.ts` ext + `docs/test-index.md` |
| 3 | **tester VERIFY 39/39 GREEN, all 6 lanes** (yupsev) | ✅ | committed evidence `evidence/integration-run-payout-cs-1781286938959-56f62b9e.json` at HEAD: `status:GREEN`, `summary {total:39, passed:39, failed:0}`, lanes 0-5 all GREEN, stack yupsev, `git_sha 56f62b9`. Offline self-check `payout-selfcheck.ts` **78/78** (tester findings §6/§7) |
| 4 | **investigator falsification GREEN** (qnccph) | ✅ | `wt-c-payb3i/next-investigator_payb3i_findings.md`: **27/27 re-derivations + 1 deliberate teeth-sentinel correctly RED** (non-vacuous), **0 unexpected**; one `BEGIN…ROLLBACK`, virtual clock both ways, own banks, every PASS attacked; corroborated not inherited; ψ envelope to orchestrator |
| 5 | **reviewer APPROVE ×2** (body-header) | ✅ | `gh pr view --json reviews`: #457 body = "✅ APPROVE … 2 LOW non-blocking nits"; #458 body = "✅ APPROVE … clean". (gh state COMMENTED per self-approve refusal — body header is the verdict) |
| 6 | **SPEC on main** | ✅ | `docs/spec/payout-cancel-sweeps-slice.md` present on `origin/main` (landed via #457) |

> Note on the migration numbering: PR #460 renumbered the unrelated **v_deposits** migration `000160 → 000230` to clear a
> duplicate-version collision on main; the payout-008 sweep keeps `…000160` and payout-010 keeps `…000170`. Verified only one
> `…000160` and one `…000170` payout migration exist on `origin/main` — no collision touches slice-3.

---

## 2. Edits applied (doc-only; +36 lines across 2 files)

**`docs/requirements/epic-payout.md` (+19):**
1. **New `### Slice-3 build status (DoD)` subsection** (after the Slice-2 block) — consolidated evidence block: green-dot
   summary + BUILD #457 / PROBES #458 / VERIFY tester 39/39 / FALSIFY investigator 27/27+1 / REVIEW APPROVE×2, plus the
   closures/decisions/residue pointer to the revision log. Heading slug `#slice-3-build-status-dod`.
2. **Payout state machine** subsection — slice-3 marker: the `pending → cancelled` auto-cancel + maintenance-cancel sweep
   edges are now LIVE; SM3 sweep-vs-claim lock-first-wins + pending-only re-derived (FZ20/FZ16/FZ6).
3. **PAYOUT-008** per-story green-dot marker (after the `**[S2 ratified]**` line) — per-age auto-cancel LIVE; **DRIFT-D8 closed**.
4. **PAYOUT-010** per-story green-dot marker — always-on maintenance sweep LIVE; **MISSING-D10 closed**; the 4 design decisions named.

**`docs/requirements/epic-payout-revision-log.md` (+17):** one `2026-06-13 (payb3 Step-4 MARK …)` entry at the top of `## 2026-06`
(newest-first) recording: evidence chain · **two closures** (DRIFT-D8, MISSING-D10) · **four pinned design decisions**
(required_bank_account_id keying / unrouted-SKIP / ba.is_active scope / `_bank_in_maintenance` reused) · **routed residue DRIFT-V**
(→ next-architect) · one investigator-named latent asymmetry (`ts_payouts_failure_code_check` omits `bank_maintenance`, safe today
→ next-architect) · the **reviewer's 2 LOW nits** (NB-457-1 dead `v_now`; NB-457-2 DECLARE-before-gate) as named follow-ups.

**Pattern fidelity:** identical structure to slice-1 (#448) and slice-2 marks — trust labels unchanged (all stay S2 ratified),
INDEX.md untouched (build/DoD state lives in the epic, not the trust-label surface).

---

## 3. Closures, decisions & routed residue (recorded in the revision log)

- **DRIFT-D8 (closed)** — the 008 sweep's wall-clock/no-grant drift (same class as slice-2's `sweep_stale_claims`): `sweep_stale_payouts`
  rewritten to `COALESCE(p_now, app_now())` + flag-gate-first + drop old `(int)` overload + `SECURITY DEFINER`/`service_role` grant + cron re-point.
- **MISSING-D10 (closed)** — the PAYOUT-010 payout-side maintenance sweep had **no producer** until now; NEW `sweep_payouts_bank_maintenance(int,timestamptz)` + cron added.
- **Four pinned design decisions** — (1) assigned-bank = `withdrawal_queue.required_bank_account_id` not `ts_payouts.system_bank_id` (FZ15 two-way);
  (2) unrouted = explicit SKIP via `IS NOT NULL` (FZ10); (3) `ba.is_active` scope (FZ12); (4) `_bank_in_maintenance` reused not forked (FZ13/14).
- **DRIFT-V (routed → next-architect)** — `v_payouts`/`v_payouts_read`/`v_deposits` `effective_status` read wall-clock `now()` (§ADR-20 T1
  read-side residue). Out of slice; **deliberately NOT a partial fix in any producer slice** — one architect-owned view-clock hardening unit.
  Prod unaffected (`now()==app_now()` on the real clock).
- **Reviewer 2 LOW nits (named follow-ups, APPROVE stands)** — NB-457-1: `…000170` dead `v_now` + redundant clock read (cosmetic);
  NB-457-2: `…000160` knob/clock reads in DECLARE precede the flag-gate (money-safety intact; move below gate for strict structural no-op).

---

## 4. DONE-WHEN ledger

- [x] Epic marks (Slice-3 DoD block + PAYOUT-008 + PAYOUT-010 green dots + state-machine slice-3 marker)
- [x] Revision-log entry (2026-06-13 payb3, top of 2026-06)
- [x] ONE docs PR open off `origin/main` — **NOT merged** (see §5)
- [x] Findings `next-pm_payb3pm_findings.md` (this file)
- [x] Reply to the orchestrator

**Epic stays NOT-done** (G2 epic-seal + LIVE signoff both owed). **Not merged** (GOAL: DO NOT MERGE).

## 5. PR

**[PR #464](https://github.com/kxlahsimx09/mb-next-payment-gateway/pull/464)** — `campaign/payb3pm` → `main`, **OPEN, NOT merged**
(doc-only: `epic-payout.md` + `epic-payout-revision-log.md` + this findings file). Title carries `[DO NOT MERGE — reviewer/owner gate]`,
matching the slice-1 (#448) / slice-2 (#455) mark convention. Held for the reviewer/owner gate.
