# next-pm findings — PAYOUT slice-1 Step-4 MARK (campaign `payb1pm`)

> **Role / posture:** build-workflow **Step 4 — MARK DONE ON EVIDENCE ONLY** (`docs/build-workflow.md`; the PM is the only role that marks; the orchestrator never marks). I marked **only on concrete evidence I verified myself at `origin/main` HEAD** before writing — no claim-based marks.
>
> **Scope marked:** PAYOUT-001, PAYOUT-002, PAYOUT-003, and the canonical Payout state machine (SM1 / SM2 / SM2-SPLIT / SM3) → **slice-DoD-done**, using the **in-slice-done-NOT-epic-done** pattern. **The payout EPIC stays NOT-done.**
>
> **Date:** 2026-06-12 · **Branch:** `campaign/payb1pm` · **HEAD verified:** `origin/main` `68b1255` (advanced from `291a705` during the pass — owner merged arch #440 + parity #441; neither touches my files, both strengthen the slice).

---

## 1. What I marked (and what I deliberately did NOT)

**Marked slice-DoD-done** (in `docs/requirements/epic-payout.md`):

- **PAYOUT-001** (create + freeze + enqueue) — per-story marker.
- **PAYOUT-002** (claim + settle + `success` + PW2 MDR fan-out) — per-story marker.
- **PAYOUT-003** (failure + release + `failed`) — per-story marker.
- **Payout state machine (canonical)** — SM1 / SM2 / SM2-SPLIT / SM3 — subsection marker.
- A consolidated **`### Slice-1 build status (DoD)`** subsection (under "Story shape at a glance") holds the full evidence chain; the four markers above link to it (anchor `#slice-1-build-status-dod`).

**Mark pattern (mine; the deposit "DoD-marks" referenced in adr.md CE4 are a *conceptual* precedent — there is no physical glyph in the deposit epic body, so I defined a clean, grep-able physical form):**
- A green-dot prose marker `🟢 Slice-1 build: DoD-GREEN … in-slice-done, NOT epic-done` on each marked story/section, each restating the G2 epic-not-done condition and linking to one consolidated evidence block.
- **Story trust labels are unchanged** — all stay `**[S2 ratified]**`. The mark records *build/verify state*, not a trust change.

**Did NOT mark (out of scope, by design):**
- **The payout EPIC** — stays not-done. Per §ADR-21 **G2**, epic-DONE owes BOTH a `next-investigator` payout **epic-seal** AND the §ADR-21 **LIVE signoff** (`live_signoff` ACCEPT). Neither has run for payout. (Same shape as the deposit epic per adr.md CE4: per-slice DoD-GREEN ≠ epic-sealed.)
- **PAYOUT-004..013** — not built, not marked.
- **INDEX.md** — left untouched. INDEX is the trust-label + one-line surface; build/DoD state lives in the epic. This is consistent with the deposit precedent (built stories DEPOSIT-007/008/010 were never annotated in INDEX). My mark pattern does not require an INDEX edit.
- No code / substrate / migrations / arch PRs touched. No merges. livegate / tunnels / sinuw untouched.

---

## 2. Evidence verified at HEAD (I went and looked — none taken on a claim)

| # | Evidence | How verified | Result |
|---|---|---|---|
| 1 | **PR #437 MERGED** (build) | `gh pr view 437` + `git ls-tree origin/main` | MERGED 2026-06-12T12:53Z. Tree carries migrations `20260612000100` / `…000110` / `…000120` + EFs `payouts-create` / `bot-queue-mark` + SPEC v2 `docs/spec/payout-core-lifecycle-slice.md`. Folds Q1 tiebreaker + Q2 residual<0 fail-close. |
| 2 | **PR #439 MERGED** (probes) | `gh pr view 439` + `git ls-tree origin/main` | MERGED 2026-06-12T13:31Z. Tree carries `tests/integration/probes/payout/` (`p001-create`, `p002-claim`, `p002-success`, `p003-failed`, `am5-invariant`, `sm2-split`, `sm3-cas`, `readiness`, `_spec`/`_assert`/`_flow`/`_stage`). |
| 3 | **Tester 71/71 GREEN** (`yupsev`) | `next-tester_payb1t_findings.md` §6 + committed evidence JSON | `evidence/integration-run-payout-1781266973439-91e2497a.json` is committed at HEAD. §6 = **71/71 PASS, all 8 lanes GREEN, runner exit 0**. |
| 4 | **Investigator 77/77 GREEN** (`qnccph`) | `wt-c-payb1i/next-investigator_payb1i_findings.md` | **VERDICT: GREEN — slice-falsification 77/77.** Independent re-derivation of every money/SM invariant inside `BEGIN … ROLLBACK` (zero-footprint), each PASS attacked. Tester 71/71 **corroborated, not inherited**. Envelope relayed to orchestrator via the psi inbox (cited by reference; the findings file is the ground-truth artifact I marked on). |
| 5 | **Reviewer APPROVE ×3** (body header) | `gh pr view <n> --json reviews` on #437/#441/#439 | **#437** `VERDICT: APPROVE` (no blocking findings) · **#441** `VERDICT: APPROVE` (deposit-lane parity mirror — byte-exact-mirror VERIFIED) · **#439** `VERDICT: APPROVE` (TEST-ONLY). gh state stays COMMENTED (self-approve refused) — verdict read from the body header per Step-3. |
| 6 | **Architect rulings Q1/Q2/Q3/Q4/C1/PV1-R** | `wt-c-payb1/next-architect_payb1_findings.md` + `gh pr view 440/441` | All rulings present. Arch **PR #440 (§ADR-10 corrective) + parity #441** were OPEN at task-issue (cited pending, not waited on) and were **owner-merged during this pass — now MERGED** (`origin/main` `291a705 → 68b1255`; they touch only `adr.md` + migration `20260612000070`, not my files). The ruled behaviour was already folded into #437 and verified before either merged, so neither was ever a slice-DoD blocker. |

**Verification gate chain is complete and mutually corroborating:** build merged → probes merged → tester GREEN from DB ground-truth → investigator independently re-derived (falsification, not inheritance) → reviewer APPROVE on all three PRs → architect rulings folded into the build. This satisfies every Step-4 per-step evidence requirement (merged PR + APPROVE + ground-truth-green) **for the per-story DoD**, while the two epic-level gates (seal + LIVE) remain explicitly owed.

---

## 3. Follow-up stories recorded (architect-opened; tracked so they are not lost)

Recorded in the payout revision log (2026-06-12 entry). **None is a slice-DoD blocker.**

- **(i) MDR config-migration story** — prod "Owner MDR" partner → next residual model (PV1-R **option (d)**, exclusive mapping) + residual-wallet representation reconciliation (`owner_type='mdr_owner'` vs `partner + is_owner`).
- **(ii) Config-write validation** — `Σ active-real-partner-pct ≤ fee_pct` per fee axis (deposit + payout) + zero-headroom flag; the landed `residual < 0` RAISE is the runtime backstop, not the primary fix.
- **(iii) Phase-2 per-client / tiered MDR-profile selection** — `client.mdr_profile_id` FK or tier-band; the deterministic tiebreaker is the Phase-1 stopgap.
- **(iv) Phase-2 §ADR-13 F2 actor-triple parity** — `created_by_{type,id,username}` on `ts_payouts` **and** `ts_deposits` together; `client_id` suffices Phase-1.
- **(v) Reviewer NB-437-2** — `mark_success` missing-client-wallet RAISE hardening (`IF FOUND` → add else RAISE, mirror `finalize_deposit`); defense-in-depth, unreachable today.

---

## 4. Deliverables / gate posture

- **Files changed (doc-only, additive +31/−0):** `docs/requirements/epic-payout.md` (+22 — consolidated block + 4 markers), `docs/requirements/epic-payout-revision-log.md` (+9 — slice-DoD entry + 5 follow-ups). INDEX.md untouched.
- **ONE docs PR opened off `origin/main`** (branch `campaign/payb1pm`, rebased onto current `origin/main` HEAD `68b1255`). **NOT merged** — the `next-code-reviewer` / owner gate stands; the PM marks, it does not self-merge doc-state into main.
- **Standing owed before payout epic-DONE (named so they don't surface late):** (1) `next-investigator` payout **epic-seal**; (2) §ADR-21 **LIVE signoff** (golden journey + faults + investigator money-invariant recompute + owner `live_signoff` ACCEPT). The composed deposit+auth LIVE run (adr.md CE-series) is the adjacent driver; the payout epic-seal is its own owed prereq.
