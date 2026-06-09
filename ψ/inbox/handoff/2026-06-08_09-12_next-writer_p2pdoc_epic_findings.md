---
title: next-writer campaign p2pdoc — epic-p2p-matching authored (REQUIREMENT lens)
from: next-writer (campaign p2pdoc)
created: 2026-06-08
status: COMMITTED to campaign/p2pdoc (b961632), AFTER next-architect ADR-17 commit (333cdac); stories S3 provisional pending owner GO
tags: [next-writer, campaign-p2pdoc, adr-17, p2p-matching, epic, requirement-lens, s3-provisional, ratification-pending]
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# campaign p2pdoc — next-writer findings (REQUIREMENT lens)

Authored `docs/requirements/epic-p2p-matching.md` — the P2P withdraw/deposit matching requirement epic, anchored on **§ADR-17** (committed FIRST by next-architect, `333cdac`). My commit: `b961632` on `campaign/p2pdoc` (NOT merged — owner merges). All 7 stories **S3 provisional `[RATIFICATION_PENDING:p2pdoc]`**; flip S3→S2 only on owner GO (§ADR-17 OQ1).

## Files (5 changed, +270)
- `epic-p2p-matching.md` NEW (223 lines, under the ≤250 cap) — house-faithful: intro · Subsystems/Repos/Dominant-trust · Why-this-matters · Story-shape-at-a-glance table · Deferred-P2P-Surface table · 7 stories (As-a/I-want/So-that · User journey · Given/When/Then ACs · per-story `Source:` line → §ADR-17 sub-decisions).
- `epic-p2p-matching-revision-log.md` NEW.
- `INDEX.md` — new `## P2P Matching` section (P2P-001..007) + `### Deferred P2P Surfaces` note.
- `glossary.md` — 3 new terms: P2P route, held-withdraw pool, destination-match.
- `README.md` — epic-index row (S3).

## Story surface (Phase-1 1:1 only — §ADR-17 MC2)
P2P-001 pool-offer (MC1/MC3/MC4/Q2) · P2P-002 P2P-route opt-in + 1:1 match + direct-to-destination no-QR (MC3/MC4/MC5) · P2P-003 slip + Thunder destination-match + off-rail dual settle, §ADR-4d V1/V2/V1.5 reused (MC5+ADR-4d) · P2P-004 fallback-timeout release to §ADR-4a rail, SLA intact (Q2) · P2P-005 slip-fail loss-bearing, system bank never eats loss, refund N/A (Q3) · P2P-006 fairness EDF+FIFO + p2p_max_amount big-amount skip (Q1/Q4) · P2P-007 promo-fraud KYC-binding + per-KYC rate-limit + self-match-exclusion + conversion-gated-bonus (Q5).

All 5 PoC open questions covered (Q1→006, Q2→004, Q3→005, Q4→006, Q5→007). Phase-2 (1:N/1:2) recorded as a Deferred P2P Surface, NOT a Phase-1 story (MC2; p2p_max_amount = hand-off seam).

## Anchor verification
Read the committed §ADR-17 directly — MC1–MC5 / Q1–Q5 / OQ1–OQ5 all match every epic Source: anchor. No invention beyond §ADR-17 + PoC `2026-05-09_poc-feasibility-p2p-withdrawdeposit-matching` (PR #41).

## Next in serialization → next-ui
My INDEX commit (b961632) is in. **next-ui** may now author `epic-p2p-matching-ui.md` and append its P2P-UI story ids to INDEX AFTER my edit (the `## P2P Matching` section is already present). Ratification (S3→S2 across all P2P stories) is the owner GO gate (§ADR-17 OQ1 + OQ2 Finance numbers) — tracked by next-pm (task #6).

## Out of scope (per charter)
UI epic = next-ui · ADR authoring = next-architect · ratifying = owner.
