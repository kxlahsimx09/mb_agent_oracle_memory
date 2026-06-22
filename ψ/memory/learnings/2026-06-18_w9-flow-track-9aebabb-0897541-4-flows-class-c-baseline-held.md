---
title: W9 pass 2026-06-18 — flow-track 9aebabb..0897541 (4 flows Class-C drift landed, baseline held, OVER-THRESHOLD → coordinated W8+W1 owed)
tags:
  - technical-writer
  - repo:mobiz-payment-gateway
  - current
  - flow-track
  - drift
  - deposit
  - payout
  - mdr
created: 2026-06-18
source: docs/flows/.baseline + docs/flows/{deposit-auto-match-from-statement,deposit-slip-upload-admin-approve,deposit-qr-request,payout-request}.md
project: github.com/kokarat/mobiz-payment-gateway
---

# W9 pass 2026-06-18 — flow-track 9aebabb..0897541

Pointer extractor healthy (254 pointers / 12 flow docs, self-test PASS). flows-baseline **held at `9aebabb`** (inherited OVER-THRESHOLD 8-flow line-shift deferral since 2026-05-22; last MERGED W9 coverage = `bb02f02` / PR #508). `last-verified-at` advanced 2026-05-22 → 2026-06-18; hash NOT bumped (deferral + Class-C drifts feeding the owed coordinated W8 revision).

**4 flows affected, all Class C (semantic drift, pointer left at prior @short, `[DRIFT]` marked in §Implementation pointers, prose rewrite deferred to W8):**
1. `deposit-auto-match-from-statement` ← `e1964b8` #530 `finalizeCheckingDeposit` auto-confirms `checking` deposits on a late single-candidate match (contradicts §Error-paths line 86 "checking → left unmatched").
2. `deposit-slip-upload-admin-approve` ← `8f29c29` #528 (4th fraud layer 409 DUPLICATE_SLIP), `b88eccb` #529 (persisted `slip_dest_status`/`slip_dest_account`, supersedes live-recompute layer ii), `7bfad9b` #521 / `d921419` #522 (client-path Thunder now fully deferred — invalidates the "client path unchanged by #460" claim). W8 scope now 5 axes + client-path defer.
3. `deposit-qr-request` ← `0897541` #542 (new dangling-MDR 422 in CreateDeposit fee block).
4. `payout-request` ← `0897541` #542 (new dangling-MDR 422 before wallet deduction).

Per-finding `#flow-drift` learnings filed: `flow-drift-530-checking-deposit-late-autoconfirm`, `flow-drift-528-529-521-522-deposit-slip-upload-extend`, `flow-drift-542-dangling-mdr-deposit-payout-create`.

**Step 0** clean: only answered thread = #4 (p2p-hub, target-system, not pg-writer territory); flow-doc markers point to pre-reset forum thread numbers, none answered, left in place. **Step 0.5**: no fresh bank-bot `#cross-repo-sync` since the 2026-05-22 flows-baseline (the #530 deposit-auto-match cross-repo sync was already filed by the W2 pass). **Step 4b**: no live section-level markers in the 4 touched docs. **Step 2c**: #542 is mobiz-internal (no shared-contract surface, no sibling-flow-doc citation) → no cross-repo link; #530's cross-repo handled in W2.

**OVER-THRESHOLD** (cumulative >5 flows incl. held 8-flow line-shift backlog + new Class-C drift across 4 flows) → recommend **coordinated W8 revision** of the deposit/payout flows + the **owed W1 re-baseline** (which is also blocking the code-level Finance/T&C/DRIFT-16…21 backlog per `current-system.md` §11). 8.B new PR (no open `docs/flow-track-*` PR). Note: prior W9 trace `38558e51` analyzed the same deposit drifts (`9aebabb..03d6383`) but its branch was never pushed — this pass lands the markers on main + adds the #542 increment.
