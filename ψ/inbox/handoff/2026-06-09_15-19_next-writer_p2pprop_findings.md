# next-writer — campaign p2pprop — handoff

**Task:** Propagate §ADR-17 §Amendment 2026-06-09 (2) — DT1–DT4 split-threshold + CK1–CK5 read-only match-preview — into the P2P design pass + requirement epic. Amendment was RATIFIED + merged on main (#361); this is propagation only (no ADR change).

**Branch:** `campaign/p2pprop` (base origin/main) · **PR #362** base `main`, **OPEN + MERGEABLE, NOT merged** (owner merges). Trust S2.

## Done
ADD-1 (split threshold): `overflow_threshold_x` → `withdrawal_overflow_threshold_x` (DT2, = today's X, gates all DP10/DP12/hybrid routing UNCHANGED) + `deposit_overflow_threshold_x` (DT3, NEW supply-side pool-eligibility class — not fee, not reject, derived predicate). Both default 5000 = no-op. OQ-A1 soft guard (warn not reject). OQ-A2 hybrid-ON large deposit pool-and-expires Phase-1.

ADD-2 (preview): new `match-preview.md` — `GET /p2p/match-preview` read-only (no row/LOCK/freeze/idem-key), aggregate-only {high|medium|low} band + facts (never counterparty/client_id/dest), no fabricated probability (band from sim's binary-instant model), `p2p_match_preview()` FOR SHARE pure-core function. NEW requirement story **P2P-011**.

## Files (10)
Design: schema.sql, data-model.md §4.0, matching-engine.md §3/§5, match-preview.md (NEW), settlement-rpcs.md §5, data-validation.md, README.md.
Requirement: epic-p2p-matching.md (P2P-001/002/007 + NEW P2P-011), INDEX.md, glossary.md (2 new terms).

## Verified
No live/lone overflow_threshold_x (remaining mentions are explicit migration notes); both split names present; P2P-011 present; preview design present; ADD-1/ADD-2 no-op for sim core match-rate.

## Out of scope / next
- admin-portal preview-UI = WUI follow-on (next-ui, campaign p2pui), dispatched AFTER admin-portal #5 merges. Not touched.
- ADR already ratified+merged; ratifying/merging = owner.
- `sim/match_sim.py` deposit_X param = recorded post-launch sim follow-up.

Findings file: `next-writer_p2pprop_findings.md` at repo root.
