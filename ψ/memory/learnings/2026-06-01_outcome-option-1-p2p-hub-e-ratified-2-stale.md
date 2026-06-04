---
title: OUTCOME (Option 1) — p2p-hub §E ratified + 2 stale notes re-pointed to ratified 
tags: [repo:p2p-hub, design-review, ratification, option-1-outcome, dispute-resolution, fee-refund, lifecycle-substrate, thread-4, thread-206, campaign-231, cross-db-caveat, notes-and-marker-only, pr-13]
created: 2026-06-01
source: system-architect §E ratification (Option 1, thread #4)
project: github.com/kxlahsimx09/p2p-hub
---

# OUTCOME (Option 1) — p2p-hub §E ratified + 2 stale notes re-pointed to ratified 

OUTCOME (Option 1) — p2p-hub §E ratified + 2 stale notes re-pointed to ratified §F. Follow-up to the 2026-06-01 §E↔§F review learning (learning_2026-06-01_review-p2p-hub-e-match-formation-reserverel; Oracle thread #4).

Human chose OPTION 1 (2026-06-01 GMT+7, thread #4): ratify §E + apply both note amendments (A mandatory + B) via a design-doc PR off fresh origin/main, notes+marker only, ZERO contract/behavior change. §E's structure was found sound and left untouched.

PR: https://github.com/kxlahsimx09/p2p-hub/pull/13 (next-architect/p2p-hub-section-e-ratify → main). NOT merged — human merges (AGENTS §9); §E #decision lands on that merge.

EDITS (docs/design/p2p-hub-design-exploration.md, 3 hunks, +23/−8):
1. §E header (~L1953): RATIFICATION_PENDING:206 → #decision. Drafting provenance preserved (next-architect 2026-05-22, thread #206 / campaign #205 / #189); status flipped to ratified-by-user-2026-06-01-thread#4.
2. Amendment A — §E1 deferral note (~L2012): §C11 dispute substrate re-pointed from superseded campaign #231 "DISPUTED lifecycle + liability-matrix ENFORCEMENT" to ratified §F append-only auto-resolution overlay (keyed by match_id, resolved_by='auto'; B12.5 never a state-flip; no Phase-1 enforcement, penalty/suspend → operator/analytics, reserved → Phase 2). Kept as deferral note (still out of 1A scope) — only the referenced model corrected.
3. Amendment B — §E8 SEAM note (~L2234): extended to name §F verification_oracle_error fail-safe (cap-exhausted ⇒ close match EXPIRED + log) as the consumer of the deferred post-charge refund-to-balance (balance += F, §C7 CQ1) + EXPIRED-from-VERIFYING transition — transfer-window pass must implement EXPIRED per ratified §F, NOT superseded §C5/§D7 FAILED/DISPUTED routing.

VERIFY: notes+marker only; no enum/table/RPC/column edits; no conflict markers; no ```mermaid fences (gate respected). §F claims grounded (P-004) against ratified §F on PR #12 branch (#decision, thread #3): F.0/F.1 auto-final, F.2/B12.5 overlay-not-state-flip, verification_oracle_error fail-safe-EXPIRED at §F L2443.

Standing findings unchanged: §F blocked on transfer-window+thunder pass (next build after §E 1A); §E7 collapse seam correct.

CROSS-DB CAVEAT (carried): this MCP cannot programmatically chain to §E thread #206 or campaign #231/#232 — linkage by tags + source lines only. The #206 (drafting) / #231 (superseded §F framing) provenance is preserved in-doc and referenced here by ID, not by trace-link.

---
*Added via Oracle Learn*
