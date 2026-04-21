---
title: drift — payout-admin-cancel (a) non-transactional write sequence leaves partial 
tags: [technical-writer, repo:mobiz-payment-gateway, current, drift, followup, flow:payout-admin-cancel, atomicity, transaction, rollback, refund, admin-cancel, payout]
created: 2026-04-21
source: docs/flows/payout-admin-cancel.md + controllers/PayoutController.go:913-1079@aff85e1 + thread #34 closed 2026-04-21
project: github.com/kokarat/mobiz-payment-gateway
---

# drift — payout-admin-cancel (a) non-transactional write sequence leaves partial 

drift — payout-admin-cancel (a) non-transactional write sequence leaves partial state on crash. The `CancelPayout` handler at `controllers/PayoutController.go:913-1079@aff85e1` performs four separate DB writes outside any `session.WithTransaction` wrapper: (1) queue CAS `pending → cancelled` at line 972-992; (2) payout CAS `pending → cancelled` at line 996-1014; (3) wallet `$inc` refund at line 1026-1033; (4) `wallets_change_logs` insert at line 1039-1059. A process crash, OOM kill, or pod rollout between any two writes leaves observably inconsistent state — most commonly queue+payout cancelled but wallet not refunded (the client wallet permanently short by `amount + payout_fee`), less commonly payout cancelled and wallet refunded but no audit row (a refund with no ledger trace).

Ruled drift/PR-needed on 2026-04-21 via thread #34 (W8 ratification of `docs/flows/payout-admin-cancel.md`). Human preference: file as **separate PR** from the companion drift `payout-auto-cancel-pending-timeout` (a) (learning `2026-04-21_drift-payout-auto-cancel-pending-timeout-a-fli.md`, ruled via thread #31 2026-04-21) rather than folding into one combined PR — each cancel path lands its transactional refactor independently for cleaner review, with cross-linked learnings so W4 picks up the shared pattern.

Fix sketch: wrap steps 5a (queue CAS) / 6a (payout CAS) / 7b (wallet $inc refund) / 8 (change-log insert) in `session.WithTransaction`. Also fold drift (c)'s `MatchedCount` guard into the same transaction body — inside a transaction, the zero-match on wallet refund aborts cleanly without the defensive compensation writes (b) would otherwise need. Operator-visible difference after fix: on a mid-sequence crash, nothing commits (not partial state); on a wallet-row-missing zero-match, the admin sees an explicit error response rather than a silent optimistic log.

W4 pickup context: this flow's sibling `payout-auto-cancel-pending-timeout` carries an identical-shape drift (thread #31 (a)) — converge on one transactional pattern across both cancel paths but file the PRs separately. When W4 schedules this, consider doing both admin+timeout flows in a single sprint so the pattern converges before new admin-rail endpoints (`/override`, `/status`) inherit the same non-transactional shape.

---
*Added via Oracle Learn*
