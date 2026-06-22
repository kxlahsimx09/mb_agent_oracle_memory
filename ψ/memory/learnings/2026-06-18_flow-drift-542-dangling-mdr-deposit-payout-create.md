---
title: flow-drift — #542 dangling-mdr 422 new error path in deposit-qr-request + payout-request (Class C)
tags:
  - technical-writer
  - repo:mobiz-payment-gateway
  - current
  - flow-track
  - flow-drift
  - drift
  - mdr
  - deposit
  - payout
  - flow:deposit-qr-request
  - flow:payout-request
created: 2026-06-18
source: controllers/DepositRequestController.go:329-334 + controllers/PayoutRequestController.go:305-310 @ 0897541
project: github.com/kokarat/mobiz-payment-gateway
---

# W9 Class-C flow drift — #542 dangling-mdr 422 new error path (deposit + payout create)

`0897541` #542 (2026-06-17, "fix(mdr): guard against dangling mdr_profile references", root cause issue #541) adds a new client-facing error branch to **both** request-creation flows: when the client has an `mdr_profile_id` assigned but the profile no longer exists (`mongo.ErrNoDocuments`), the create handler now rejects with **`422 Unprocessable Entity`** ("Configured MDR profile not found …") instead of warn-and-continue at fee=0.

- `deposit-qr-request` flow — `controllers/DepositRequestController.go:329-334` (`rejectDeposit(…, 422, …)` in the deposit-fee block). The flow's §Error paths lists 401/400/503/429 rejections but not this dangling-MDR 422.
- `payout-request` flow — `controllers/PayoutRequestController.go:305-310` (`rejectPayout(…, 422, …)` in the MDR-fee lookup between Step 2 validation and Step 3 wallet deduction).

W9 action: added a `[DRIFT]` bullet to each flow's §Implementation pointers (pointer-section flag only; §Error-paths prose deferred to the W8 revision). Class C. A client with **no** assigned `mdr_profile_id` is unaffected (the lookup only runs when a profile is assigned), so the 422 fires on *dangling* references only. Related code-level drift: `current-system.md` §9 DRIFT-21 (the same #542 commit; W2 amend PR #540). flows-baseline held at `9aebabb`.
