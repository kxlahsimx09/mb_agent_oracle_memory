---
title: LIVE GATE design — the 5th gate for mb-next (campaign nextteam, designed 2026-06
tags: [nextteam, live-gate, adr-21, definition-of-done, next-live-runner, next-investigator, real-bank-mode, mb-next-payment-gateway, epic-acceptance]
created: 2026-06-01
source: orchestrator campaign nextteam — LIVE gate workflow + owner two-mode refinement 2026-06-01
project: github.com/soul-brews-studio/arra-oracle-v3
---

# LIVE GATE design — the 5th gate for mb-next (campaign nextteam, designed 2026-06

LIVE GATE design — the 5th gate for mb-next (campaign nextteam, designed 2026-06-01 via orchestrator workflow + owner refinement). To be ratified as §ADR-21. Full prose: workflow output at /private/tmp/claude-502/claude-502/-Users-admin-Code-github-com-Soul-Brews-Studio-arra-oracle-v3-wt-8-orec/14a38173-102d-4252-a2da-150f02656db6/tasks/w8izvgu6f.output

== WHAT ==
LIVE = a once-per-epic gate firing AFTER the next-investigator epic-seal and BEFORE next-pm marks the epic DONE. It deploys the REAL artifacts (EFs, migrations, CF Worker with rate-limit binding live, Fargate egress in real CONNECT-tunnel mode) onto a LIVE-mode stack with the clock pinned to REAL time (clock_advance/clock_set guarded off), pushes ONE real money journey end-to-end through the real wire (client→Worker→EF→RPC→Realtime→egress→HMAC callback), injects exactly 3 faults each tied to a zero-tolerance rule, then the investigator reads money invariants off GROUND-TRUTH TABLES (never the harness's own success flags) and signs a technical verdict. next-pm renders it as a one-page money-timeline; owner clicks ACCEPT to AUTHORIZE done.

== LAYERED DoD ==
per-story: SPEC→BUILD→REVIEW→VERIFY{tester probes + investigator V1-V5} (virtual clock, mocked seams). per-epic: EPIC SEAL (investigator completeness audit). NEW per-epic: LIVE (real clock 1x, real wire+egress, real alarms). pre-release: full-suite LIVE across all closed epics. DONE rule (teeth): next-pm marks epic DONE only when BOTH investigator seal AND an append-only live_signoff ACCEPT row (keyed to run request_id + owner identity) exist; REJECT/absent blocks DONE, routes back to dev.

== 5 COMPONENTS ==
L0 LIVE-mode stack (MVP: flip existing test/perf stack to REAL mode, no 5th project) — brew-ops. L1 one golden money journey (DEPOSIT first), real HTTP client→real wire→terminal — next-tester builds (extends run-hosted.ts), next-live-runner runs, investigator verdict. L2 three mapped faults: dup bank-txn→dup-credit=0; callback timeout→dup-egress=0; one MUST-PAGE fault→§ADR-15 alert actually fires (de-theaters "no alerts"). L3 investigator recomputes 4 invariants from raw tables (conservation; exactly-one callback byte-matching net; balance≥frozen; money in/out exactly once) + confirms expected alert fired & no unexpected alert. L4 owner card: /live/<epic> swimlane (sibling to /probes) + screen recording + mandatory honest-boundary footer — next-pm. L5 immutable live_signoff append-only row; ACCEPT=authorization — OWNER alone.

== TWO MODES (owner refinement 2026-06-01) ==
Mode SIM (default, automated, per-epic gate): bank seam = mock-bank/bot-simulator, no human, fast. Mode REAL-BANK (added later, AFTER bank-bot is implemented; milestone cadence not per-epic): bank seam = real bank-bot + real TEST bank accounts (can send/receive real THB); journey PAUSES at a human step ("transfer X THB to test account Y"); a human does the real transfer → real statement appears → REAL scraper + REAL parser → match → settle; PAYOUT direction sends to a real test account and confirms receipt = full real-money round-trip. REAL-BANK is the ONLY mode that exercises the real scraper + real bank statement parsing — the historical #1 failure surface (bank portal HTML change, new bank dialect) — so it closes honest-limit #1 (real bank) + #2 (scraper). Both modes share the same journey + 4 invariants + investigator ground-truth read + owner card; differ only by bank seam + human-transfer step; toggle via one flag (like EGRESS_MODE). Cadence REAL-BANK: after bank-bot lands / before stable cut / when scraper or bank-parsing changes / new bank dialect.

== NEW ARTIFACTS ==
§ADR-21 ratifies LIVE (owner GO per §ADR-18/20 convention). New role next-live-runner (thin "live" hat, can be next-tester wearing it) — HARD independence rule: must NOT be next-investigator (runner ≠ verdict). case-mix.json hardcoded constant (NOT a prod-replica profiler — recurring cost + PII-adjacency vs §ADR-20 E5; distribution stable to 0.1% over 6mo, refresh manually quarterly). live_signoff append-only table + ACCEPT/REJECT. journeys/deposit-to-callback.ts; /live/<epic> renderer.

== HONEST LIMITS (skeptic-surfaced; the owner card must state them) ==
(1) real bank/merchant not tested in SIM mode (closed only by REAL-BANK mode). (2) MVP/SIM does NOT test the scraper (closed only by REAL-BANK mode) — top gap. (3) one-shot per-epic gate can't catch a regression a LATER epic introduces in shared code (e.g. WALLET-LEDGER); v2 = always-on canary WITH a defined "un-DONE the epic" path, else informational only. (4) latency/throughput NOT gated (only logic invariants) — shared-burstable degrades at ~30 dep/s, a gating soak would flake correct epics red; soak only on cpu_dedicated, informational never gating. (5) owner ACCEPT = authorization NOT proof (teeth = investigator ground-truth re-read). (6) one representative journey, not coverage (layers on top of VERIFY+seal).

== MVP ==
DEPOSIT SIM mode first (highest money risk): flip test/perf to REAL clock; 1 journey + 3 faults; investigator 4 invariants from raw tables; owner card+recording; DONE=seal AND ACCEPT. ~2-3 days next-tester, $0 new infra. OUT of MVP (v2): REAL-BANK mode, PAYOUT journey, standing 5th project, prod-replica profiler, soak, always-on canary-as-gate.

---
*Added via Oracle Learn*
