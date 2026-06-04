---
title: When a design ruling splits a fault class into sub-cases, sync EVERY requirement
tags: [p2p-hub, requirements, fault-class, wrong_amount, matched_overpaid, settle-gate, design-sync, P-004]
created: 2026-06-01
source: next-product-writer (PR #20, refs §F/§G + thread #7)
project: github.com/kxlahsimx09/p2p-hub
---

# When a design ruling splits a fault class into sub-cases, sync EVERY requirement

When a design ruling splits a fault class into sub-cases, sync EVERY requirements-side table that summarizes that matrix — not just the primary epic. In p2p-hub the `wrong_amount` over/under split (design §F.1/§F.3/§G6/§G8, merged PR #19, ratified `#decision` thread #7 2026-06-01) had to land in BOTH `docs/requirements/epic-dispute-liability.md` (DISPUTE-002 matrix + DISPUTE-003 close_outcome contract) and `docs/requirements/fault-class-catalogue.md` in one PR.

The ruling (P-004 code/doc-is-truth — trust the merged design over any brief):
- `wrong_amount` under (`actual < M`) → `matched_incomplete`: FAILS the §G6 amount clause (`actual >= M`); does NOT settle; payout side RELEASES the full reserved M (`release_reserve`); shortfall is a DSP↔its-own-depositor matter; no inter-provider debit, no hub money movement, no human.
- `wrong_amount` over (`actual > M`) → `matched_overpaid` (NEW live outcome): PASSES §G6; the match SETTLES at the agreed M (`settle_p2p_match` debits exactly M; destination received ≥ M so the withdrawer is made whole); excess X = actual − M is unrecoverable, WRITTEN OFF as DSP-fault (hub can't claw back, §A7/§B1.2; ⟦S3⟧ DSP signal). NOT a release. Auto-final (`resolved_by='auto'`) but — unlike `matched_incomplete` — it DOES move money.
- close_outcome contract: live 6 → 7 (add `matched_overpaid`); reserved stays 5; total 12.
- §G6 settle gate amount clause evolved from `actual == M` to `actual >= M (settles at M)`; the `genuine` and `delivered` clauses are unchanged. Also propagate `== M` → `>= M` in any downstream predicate (e.g. `customer_non_receipt` = `genuine ✓ AND actual >= M BUT delivered=false`).
- P-001: `matched_incomplete` is kept (the under case), not renamed.

Mechanical gotcha: splitting one matrix row into two adds a physical line — watch the ≤250-line file cap. Consolidate adjacent same-concern paragraphs (e.g. merge the two "Reserved → Phase 2" blocks into one) rather than dropping content.

Delivered as PR #20 off fresh origin/main (no merge, no AI attribution).

---
*Added via Oracle Learn*
