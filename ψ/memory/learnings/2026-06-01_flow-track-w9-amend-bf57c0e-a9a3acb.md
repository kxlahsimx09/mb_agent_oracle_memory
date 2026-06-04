---
title: W9 flow-track amend bf57c0e..a9a3acb — payout-admin-cancel Class C drift (#505); baseline held at 9aebabb
tags: [technical-writer, repo:mobiz-payment-gateway, current, flow-track, flow:payout-admin-cancel, w9]
created: 2026-06-01
source: docs/flows/payout-admin-cancel.md
related:
  - 2026-06-01_flow-drift-payout-admin-cancel-refund-changelog-entity-wallet
project: github.com/kokarat/mobiz-payment-gateway
---

W9 amend pass 2026-06-01 (evening), range `bf57c0e..a9a3acb` (2 commits),
extending PR #508. Pointer extractor self-test healthy: 253 pointers across 12
flow docs.

Per-class outcome:
- **C (step drift): 1** — `payout-admin-cancel` step 8 (`CancelPayout` refund
  change-log) re-keyed `entity_type=client → wallet` by #505 (`a9a3acb`). Marked
  `[DRIFT]` in §Postconditions + `[DRIFT-2]` on the Step 8 pointer; pointer held
  at `@d2a2738`. See `2026-06-01_flow-drift-payout-admin-cancel-...`.
- **A/B: 0 refreshed** — `payout-confirm-completed` + `payout-request` pointers at
  `PayoutController.go:1820-2123` shifted (+16 lines from #505's two insertions
  above them), but these are **folded into the prior pass's inherited 8-flow
  line-shift deferral** (baseline already held at `9aebabb`); not refreshed
  per-pointer this pass.
- **D/E/F: 0.**
- **Uncovered/no-coverage:** `88506f3` #509 (bank-account admin edit) touches
  `BankAccountController` which **no flow references** — not a class-D step (no
  existing flow territory) and not a greenfield actor-crossing worth a W8 flow, so
  no `#uncovered-surface` handoff. The #505 sibling refund sites in
  `PayoutController` UpdatePayoutStatus→failed (~948) and
  `PayoutRequestController` client-cancel (~757) are not flow-covered → no marker.

`docs/flows/.baseline` **held at 9aebabb** (prior deferral unchanged). Step 0.5:
no fresh bank-bot `#cross-repo-sync` learnings since 2026-05-22 baseline. Step 2c:
no cross-repo signal (#505/#509 touch no bank-bot contract surface). Extends W9
PR #508 (amend, Step 8.A).
