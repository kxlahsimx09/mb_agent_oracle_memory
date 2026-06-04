---
title: ## DEC-E refinement (user 2026-06-04): reverse-settle MDR-unwind is PER-PARTNER 
tags: [adr, payout, reverse-settle, mdr-unwind, all-or-nothing, money-safety, reconciliation, campaign-payfix, next-architect]
created: 2026-06-04
source: docs/adr.md §ADR-10 §Amendment 2026-06-04 PW3 (PR #323); user refinement 2026-06-04 campaign payfix
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# ## DEC-E refinement (user 2026-06-04): reverse-settle MDR-unwind is PER-PARTNER 

## DEC-E refinement (user 2026-06-04): reverse-settle MDR-unwind is PER-PARTNER ALL-OR-NOTHING, not best-effort-partial

Correction/refinement to the payfix DEC-E ruling (supersedes the earlier "best-effort" phrasing in `learning_2026-06-04_payout-correction-state-machine-bundle-ratifi`). The MDR claw-back on a payout `reverse_settle` (success→failed correction) is **per partner, all-or-nothing**:
- partner wallet CAN fully cover its share → deduct the FULL share (normal unwind)
- CANNOT (already withdrew / insufficient) → deduct NOTHING, leave the wallet untouched, write an AUDIT row for the FULL unrecovered share as a documented shortfall

NEVER a partial deduction; NEVER a forced negative balance. Rationale (user): a clean audit-tracked shortfall of the FULL amount nets/reconciles against the partner far more cleanly later than a messy partial deduction that leaves an odd residue. The `is_owner` residual leg always covers its own unwind (platform-owned, no shortfall there). The whole reverse_settle txn STILL commits even when a partner is short — the shortfall is an auditable receivable, never a blocker (the client re-credit is the load-bearing move and must commit).

General lesson: "best-effort, recover what's available" and "all-or-nothing, full-or-audit-only" are genuinely different money policies — the user preferred the latter precisely because partial deductions are harder to reconcile than a clean full-amount receivable. When an architect drafts "best-effort partial", surface the all-or-nothing alternative explicitly; the reconciliation ergonomics often favor it. Encoded in §ADR-10 §Amendment 2026-06-04 PW3 (PR #323, branch arch/payfix-adr).

---
*Added via Oracle Learn*
