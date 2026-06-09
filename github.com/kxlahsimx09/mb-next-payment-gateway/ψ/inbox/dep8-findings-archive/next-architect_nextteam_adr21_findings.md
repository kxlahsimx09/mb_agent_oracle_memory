# next-architect — campaign `nextteam` — §ADR-21 (LIVE, the 5th Gate) FINDINGS

**Date:** 2026-06-01 · **Branch:** `campaign/nextteam-adr21` (rebased onto origin/main `d4c42de`) · **PR:** #301, open, base `main`, **MERGEABLE**, **NOT merged** (charter §9 — the owner merges) · **Status:** ✅ **RATIFIED `#decision` (user GO 2026-06-01).** All sub-decisions (G1–G2 + L0–L5 + M1–M2 + R1–R2 + C1) + OQ1–OQ5 flipped from `#provisional` `[RATIFICATION_PENDING:nextteam]` to `#decision`, per the §ADR-18 / §ADR-20 convention — architect lean accepted in whole, no overrides.

Authoritative source: Oracle learning *"LIVE GATE design — the 5th gate"* (`learning_2026-06-01_live-gate-design-the-5th-gate-for-mb-next-campa`) + the orchestrator workflow output + the owner GO relay (2026-06-01). House style modelled on §ADR-20.

**ADR-number check (verify-against-HEAD `1fc5f2f`):** ADR-20 is the highest landed ADR; ADR-17 is reserved (P2P); concurrent ng2arch is on §ADR-18/§ADR-19 + amendments to §ADR-9/10/12/15 — **no ADR-21 anywhere.** ADR-21 is the correct next free number, disjoint. **Ratification pass:** rebased onto latest origin/main (`d4c42de` — ng2arch/UI/runbook PRs #297/#300/#304 landed) cleanly, **no docs/adr.md conflict**; verified **no `<<<<<<<` markers**, **ADR-21 heading appears exactly once**, **no live-body `[RATIFICATION_PENDING:nextteam]` markers remain** (only the preserved P-001 historical authoring revision-log entry + narrative mentions). `gh pr view 301 --json mergeable` = **MERGEABLE**.

---

## The decisions (RATIFIED `#decision` — user GO 2026-06-01)

**Part G — the gate + its teeth**
- **G1** — LIVE is one **once-per-epic** gate, fired **AFTER** the next-investigator epic-seal and **BEFORE** next-pm marks DONE. Five-gate layered DoD: VERIFY (per story) → EPIC SEAL (per epic) → **★ LIVE (new, per epic)** → PRE-RELEASE full-suite. Re-fires only if the epic's substrate changes.
- **G2 (load-bearing teeth)** — an epic is DONE only when **BOTH** an investigator epic-seal **AND** an append-only `live_signoff` **ACCEPT** row exist (keyed to run `request_id` + owner identity). REJECT/absent **blocks DONE**, routes back to dev with the failed lane named.

**Part L — five components + owners**
- **L0** LIVE-mode stack — real artifacts, clock pinned REAL (`clock_*` guarded off), egress in real tunnel mode. MVP flips the §ADR-20 `test/perf` stack to REAL; **no 5th project.** → **brew-ops.**
- **L1** one golden money journey (DEPOSIT first), real HTTP client → real wire → terminal. → next-tester builds (extends `run-hosted.ts`) **and runs** / next-investigator verdict.
- **L2** three mapped faults: dup bank-txn → dup-credit=0; callback timeout → dup-egress=0; **one MUST-PAGE fault → §ADR-15 alert actually fires** (de-theaters "no alerts"). → next-tester wires flags **and runs**.
- **L3** independent ground-truth read: investigator recomputes **4 invariants from RAW tables** (conservation; exactly-one callback byte-matching net; balance≥frozen; money in/out exactly once) + confirms expected alert fired & no unexpected alert. **Never the harness's flags** (§D.6 lesson). → **next-investigator** (the teeth).
- **L4** owner card: `/live/<epic>` swimlane (sibling to `/probes`) + recording + **mandatory honest-boundary footer**; case-mix shown as "test conditions," never a pass signal. → next-pm presents / next-tester renderer.
- **L5** immutable `live_signoff` append-only row; **ACCEPT = owner authorization, not proof.** → **OWNER alone.**

**Part M — the two modes (one flag toggles; share journey + invariants + investigator-read + owner-card)**
- **M1 SIM** (DEFAULT, automated, the per-epic gate) — bank seam = `mock-bank`/`bot-simulator`, no human, fast. Does NOT exercise the real scraper.
- **M2 REAL-BANK** (added LATER, after bank-bot lands; **milestone cadence, not per-epic**) — real bank-bot + real TEST bank accounts; journey PAUSES at a **human-in-the-loop transfer**; real statement → **REAL scraper + REAL parser** → match → settle; **PAYOUT = real-money round-trip** to a test account. **The only mode that exercises the real scraper + bank-statement parsing → closes honest-limits #1 (real bank) + #2 (scraper).**

**Part R — role + case-mix**
- **R1 (owner correction 2026-06-01)** — the LIVE-run is a **next-tester responsibility, NO new role.** next-tester already builds+runs the harness and is already independent of next-investigator, so the binding rule **"the agent that RAN the journey ≠ the agent that gives the PASS/FAIL verdict"** is already satisfied. A 6th `next-live-runner` role is **rejected (A0)** — SKILL + fleet + tracking overhead for zero independence gain. Fleet stays at **5** `nextteam` build roles.
- **R2** `case-mix.json` **hardcoded constant**, refreshed quarterly — **NOT a prod-replica profiler** (recurring cost + PII-adjacency vs §ADR-20 E5; distribution stable to 0.1% over 6mo).

**Part C — cadence**
- **C1** — per-epic SIM mandatory + cross-epic milestone (DEPOSIT once its neighbours are sealed) + REAL-BANK milestone + pre-release full-suite. **Always-on canary deferred to v2** (needs an "un-DONE the epic" path or it's informational only).

**MVP** = DEPOSIT, Mode SIM, ~$0 infra (flip test/perf to REAL clock, no soak, no 5th project), ≈ 2–3 days next-tester. **v2** = REAL-BANK / PAYOUT / canary / soak / 5th project / portal-sandbox / profiler.

---

## Honest limits (the L4 card MUST state them)
1. Real bank/merchant **not** tested in SIM → closed only by M2 REAL-BANK.
2. SIM does **not** test the scraper (the #1 historical failure surface) → closed only by M2. *(Top reason M2 exists.)*
3. One-shot per-epic gate can't catch a regression a **later** epic introduces in shared code → open risk until the v2 canary + "un-DONE" path.
4. Latency/throughput **not gated** (shared-burstable degrades at ~30 dep/s; a gating soak would flake correct epics red) — soak only on dedicated CPU, informational never gating.
5. Owner ACCEPT = **authorization, not evidence** (teeth = L3 investigator ground-truth re-read).
6. One representative journey, not coverage (layers on top of VERIFY + seal).

---

## Owner GO — OQ1–OQ5 all RESOLVED (user GO 2026-06-01, per the architect lean, no overrides)
- **OQ1 (load-bearing)** — ✅ **RATIFIED:** G1 (the 5th gate, after seal / before DONE) + G2 (DONE = investigator seal AND `live_signoff` ACCEPT; absent/REJECT blocks).
- **OQ2** — ✅ **RATIFIED:** R1 — LIVE-run = next-tester responsibility, **NO 6th role**; "agent that ran ≠ agent that verdicts" met by next-tester ≠ next-investigator; A0 rejected; **fleet stays at 5.**
- **OQ3** — ✅ **RATIFIED:** M1 SIM = default per-epic gate now + M2 REAL-BANK = later milestone mode (real bank-bot + test accounts + human transfer + PAYOUT round-trip; only mode exercising the real scraper).
- **OQ4** — ✅ **RATIFIED:** R2 — `case-mix.json` hardcoded constant, quarterly refresh, no prod-replica profiler (§ADR-20 E5).
- **OQ5** — ✅ **RATIFIED:** MVP = DEPOSIT/SIM/~$0-infra (flip test/perf to REAL, no soak, no 5th project); REAL-BANK/PAYOUT/canary/soak/5th-project = v2.

**Locked defaults at ratification (owner-amendable later):** (1) DEPOSIT-first journey · (2) M1 SIM default mode · (3) MVP substrate = the §ADR-20 `test/perf` stack flipped to REAL clock, **no standing 5th Supabase project** · (4) **no soak** in MVP (if ever added: dedicated CPU only, informational/non-gating) · (5) always-on **canary deferred to v2** (needs an "un-DONE the epic" path first).

**Deferrable impl choices — left OPEN (do NOT block ratification; bounced to the named owner):** (i) which specific §ADR-15 alert is the must-page fault (L2-iii) → next-tester / next-investigator; (ii) the `live_signoff` schema home + the `/live/<epic>` renderer → next-tester / next-pm; (iii) the SIM/REAL-BANK toggle flag name → next-tester.

---

## What each role must BUILD on owner GO (downstream handoff)
- **brew-ops:** (a) L0 — flip the `test/perf` stack to REAL-clock LIVE mode for the run (clock pinned, `clock_*` guarded off); (b) v2/M2 — provision the real bank-bot + real TEST bank accounts + the human-step runbook (gated on bank-bot landing). *(No `next-live-runner` SKILL — role rejected, R1/A0.)*
- **next-tester:** (a) L1 — `journeys/deposit-to-callback.ts`, extending `run-hosted.ts` (real client → real wire → terminal) **+ RUN it (the live-run responsibility, R1)**; (b) L2 — wire the three fault-injection env flags (`mock-merchant` `timeout_always` exists; `mock-bank` dup-credit re-emit) + run them; (c) L4 — the `/live/<epic>` trace-to-swimlane renderer (with next-pm) + produce the recording; (d) R2 — author `case-mix.json` + the citing aggregation query. **Must never also be the verdict-giver** (already met: next-tester ≠ next-investigator).
- **next-investigator:** L3 — recompute the 4 money invariants from raw tables + confirm the must-page alert fired / no unexpected alert; sign the technical verdict. Owns PASS/FAIL only.
- **next-pm:** L4 — present the `/live/<epic>` card (honest footer mandatory); L5/G2 — enforce DONE = seal AND `live_signoff` ACCEPT (build the ACCEPT/REJECT control + append-only `live_signoff` table with next-tester).

---

## OUT OF SCOPE for this ADR (bounced to owners)
The journey/harness/renderer code (next-tester/next-pm); the `live_signoff` table shape; production code; provisioning; the REAL-BANK runbook (brew-ops + owner, gated on bank-bot). *(No `next-live-runner` SKILL — the role was rejected per the owner correction; R1/A0.)*
